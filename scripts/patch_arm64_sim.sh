#!/bin/bash
# =============================================================================
# patch_arm64_sim.sh
# Inject an arm64 iOS-Simulator slice into pre-built MLKit xcframeworks by
# retargeting the arm64 *device* binary's Mach-O LC_BUILD_VERSION platform
# field from 2 (IOS) to 7 (IOSSIMULATOR), then merging with the existing
# x86_64 simulator slice.
#
# Technique credit: iwater/google-mlkit-ios-arm64-simulator (adapted to SPM,
# using the python3 in-place byte-patch which is the only path that works on
# the object files inside MLKit's static archives under the Xcode 26/27 vtool).
#
# Usage: patch_arm64_sim.sh <INPUT_XCFRAMEWORKS_DIR> <OUTPUT_DIR>
#   INPUT layout:  <INPUT>/<Name>/<Name>.xcframework   (SPM artifacts layout)
#              or  <INPUT>/<Name>.xcframework          (flat layout)
# =============================================================================
set -euo pipefail

INPUT_DIR="${1:?input dir}"
OUTPUT_DIR="${2:?output dir}"
SIM_PLATFORM=7
MIN_IOS="15.5"

mkdir -p "$OUTPUT_DIR"

log() { echo "[patch] $*"; }

# Modules that already ship an arm64 simulator slice -> copy through untouched.
PASSTHROUGH=(GoogleToolboxForMac SSZipArchive)

is_passthrough() {
  local n="$1"
  for p in "${PASSTHROUGH[@]}"; do [[ "$p" == "$n" ]] && return 0; done
  return 1
}

# Patch ONE thin Mach-O file (object or dylib) in place: set platform -> simulator.
# Strategy (mirrors iwater priority):
#   1) vtool -set-build-version -replace  (converts LC_VERSION_MIN_* -> LC_BUILD_VERSION,
#      and works whenever the file has room)
#   2) python3 in-place overwrite of an existing LC_BUILD_VERSION platform field
#      (needed for objects where vtool reports "not enough space")
# Returns 0 on success, 1 on failure.
patch_one_macho() {
  local f="$1"
  if vtool -arch arm64 -set-build-version "$SIM_PLATFORM" "$MIN_IOS" "$MIN_IOS" -replace \
       -output "$f.__sim" "$f" 2>/dev/null; then
    mv "$f.__sim" "$f"; return 0
  fi
  rm -f "$f.__sim"
  python3 - "$f" "$SIM_PLATFORM" <<'PY'
import struct, sys
f, plat = sys.argv[1], int(sys.argv[2])
data = bytearray(open(f, 'rb').read())
if len(data) < 32: sys.exit(1)
magic = struct.unpack_from('<I', data, 0)[0]
off = 32 if magic == 0xfeedfacf else (28 if magic == 0xfeedface else None)
if off is None: sys.exit(1)
soc = struct.unpack_from('<I', data, 20)[0]
end = off + soc; i = off
while i < end - 8:
    cmd = struct.unpack_from('<I', data, i)[0]
    cs  = struct.unpack_from('<I', data, i + 4)[0]
    if cs < 8 or i + cs > end: break
    if cmd == 0x32:  # LC_BUILD_VERSION
        struct.pack_into('<I', data, i + 8, plat)
        open(f, 'wb').write(data); sys.exit(0)
    i += cs
sys.exit(2)
PY
}

# Patch every Mach-O object (.o) in a directory in place.
patch_objects_dir() {
  local dir="$1" ok=0 miss=0
  for obj in "$dir"/*.o; do
    [[ -f "$obj" ]] || continue
    if patch_one_macho "$obj"; then ok=$((ok+1)); else miss=$((miss+1)); fi
  done
  echo "    objects: patched=$ok failed=$miss"
  [[ $miss -eq 0 ]]
}

# Patch a single Mach-O binary (not an archive) in place.
patch_single_macho() {
  if patch_one_macho "$1"; then echo "    single macho: patched"; return 0
  else echo "    single macho: FAILED"; return 2; fi
}

process_one() {
  local name="$1" xc="$2"
  local out="$OUTPUT_DIR/${name}.xcframework"
  rm -rf "$out"

  if is_passthrough "$name"; then
    cp -R "$xc" "$out"
    log "$name: passthrough (already universal)"
    return
  fi

  local dev_fw sim_fw
  dev_fw=$(find "$xc" -type d -path "*ios-arm64/*.framework" ! -path "*simulator*" | head -1)
  sim_fw=$(find "$xc" -type d -path "*simulator*/*.framework" | head -1)
  if [[ -z "$dev_fw" ]]; then log "$name: SKIP (no ios-arm64 device slice)"; return; fi

  local bin_name; bin_name=$(basename "$dev_fw" .framework)
  local work; work=$(mktemp -d)
  mkdir -p "$work/device" "$work/sim"
  cp -R "$dev_fw" "$work/device/${bin_name}.framework"
  cp -R "$dev_fw" "$work/sim/${bin_name}.framework"
  local devbin="$work/device/${bin_name}.framework/${bin_name}"
  local simbin="$work/sim/${bin_name}.framework/${bin_name}"

  # extract arm64 (device binary may be a thin-fat wrapper)
  local arm64bin="$work/arm64.bin"
  if lipo -info "$devbin" 2>/dev/null | grep -q "Architectures in the fat file"; then
    lipo -thin arm64 "$devbin" -output "$arm64bin"
  else
    cp "$devbin" "$arm64bin"
  fi

  local ftype; ftype=$(file -b "$arm64bin")
  local patched_arm64_sim="$work/arm64_sim.bin"
  if echo "$ftype" | grep -qi "archive"; then
    # static library: explode, patch each .o, re-libtool
    local ar="$work/ar"; mkdir -p "$ar"; ( cd "$ar"
      idx=0
      for m in $(ar t "$arm64bin" | grep -v '^__\.SYMDEF'); do
        ar p "$arm64bin" "$m" > "$(printf 'o_%05d.o' "$idx")" 2>/dev/null || true
        idx=$((idx+1))
      done
      chmod 644 *.o 2>/dev/null || true )
    patch_objects_dir "$ar" || log "$name: WARN some objects lacked LC_BUILD_VERSION"
    ( cd "$ar" && libtool -static -no_warning_for_no_symbols -o "$patched_arm64_sim" *.o )
  else
    # single Mach-O (dylib/object)
    cp "$arm64bin" "$patched_arm64_sim"
    patch_single_macho "$patched_arm64_sim" || log "$name: WARN single macho patch missed"
  fi

  # build the simulator fat binary: patched arm64 + existing x86_64 (if present)
  if [[ -n "$sim_fw" ]]; then
    local x86bin="$work/x86.bin" have_x86=false
    if lipo -info "$sim_fw/${bin_name}" 2>/dev/null | grep -q "Architectures in the fat file"; then
      # fat sim binary -> pull the x86_64 slice out
      lipo -thin x86_64 "$sim_fw/${bin_name}" -output "$x86bin" 2>/dev/null && have_x86=true
    elif file -b "$sim_fw/${bin_name}" | grep -q "x86_64"; then
      # already a thin x86_64 binary -> use directly
      cp "$sim_fw/${bin_name}" "$x86bin"; have_x86=true
    fi
    if $have_x86; then
      lipo -create "$patched_arm64_sim" "$x86bin" -output "$simbin"
    else
      cp "$patched_arm64_sim" "$simbin"
    fi
  else
    cp "$patched_arm64_sim" "$simbin"
  fi
  cp "$arm64bin" "$devbin"

  rm -rf "$out"
  xcodebuild -create-xcframework \
    -framework "$work/device/${bin_name}.framework" \
    -framework "$work/sim/${bin_name}.framework" \
    -output "$out" >/dev/null 2>&1 || { log "$name: create-xcframework FAILED"; rm -rf "$work"; return 1; }

  local sims; sims=$(ls "$out" | grep -i simulator | head -1)
  log "$name: OK  device=ios-arm64  sim=${sims} ($(lipo -info "$out/$sims/${bin_name}.framework/${bin_name}" 2>/dev/null | grep -oE '(arm64|x86_64)( arm64| x86_64)*' | tail -1))"
  rm -rf "$work"
}

log "=== patching xcframeworks from $INPUT_DIR -> $OUTPUT_DIR ==="
shopt -s nullglob
declare -a XCS=()
# SPM artifacts layout: <INPUT>/<Name>/<Name>.xcframework
for d in "$INPUT_DIR"/*/*.xcframework; do XCS+=("$d"); done
# flat layout fallback
if [[ ${#XCS[@]} -eq 0 ]]; then for d in "$INPUT_DIR"/*.xcframework; do XCS+=("$d"); done; fi

for xc in "${XCS[@]}"; do
  name=$(basename "$xc" .xcframework)
  process_one "$name" "$xc" || log "$name: ERROR"
done
log "=== done. output modules: $(ls "$OUTPUT_DIR" | grep -c xcframework) ==="
