# Google MLKit SwiftPM Wrapper (mdata-group fork)

This is a SwiftPM binary-distribution wrapper around Google ML Kit. ML Kit ships
only via CocoaPods, so this repo rebuilds those pods into XCFrameworks, zips
them, publishes the zips as GitHub Release assets, and exposes 17 SwiftPM library
products whose `binaryTarget`s point at those zips.

> **This is a fork of [`d-date/google-mlkit-swiftpm`](https://github.com/d-date/google-mlkit-swiftpm).**
> It carries two fork-only patches that upstream (and the official ML Kit CocoaPods)
> do **not** ship. Both are documented in detail under
> [Fork patches](#fork-patches) below:
>
> | Fork release | Problem it fixes |
> |---|---|
> | **`9.0.0-textfix5`** | Latin/CJK text recognition crashing at runtime — `MLKTextRecognizerInternalErrorCreationFailure "Invalid model path."` and (in Release/TestFlight builds) `dyld: symbol not found in flat namespace '_MLKMillisecondsPerSecond'`. |
> | **`9.0.0-simfix2`**  | No `arm64` iOS-Simulator slice. On Apple Silicon + Xcode 26/27 (Rosetta simulators dropped) the stock binaries have **no runnable simulator slice at all**. Ships everything `9.0.0-textfix5` fixes **plus** an injected `arm64` simulator slice. |
>
> **Use `9.0.0-simfix2`** — it is the current, self-contained release and is a
> strict superset of `9.0.0-textfix5`.

## Requirements

- iOS 15 and later
- Xcode 15 and later (Xcode 26/27 supported — that is the whole point of `9.0.0-simfix2`)

## Installation

### 1. Add the package dependency

```swift
dependencies: [
    // Recommended: the fork release with both patches (text-recognition + arm64 simulator).
    // simfix tags are SemVer pre-releases, so `from:`/`upToNextMajor` will NOT resolve
    // them — you must pin with `exact:`.
    .package(url: "https://github.com/mdata-group/google-mlkit-swiftpm", exact: "9.0.0-simfix2")
]
```

In an Xcode project (not a `Package.swift`), add the package with
**Exact Version** = `9.0.0-simfix2` and repository URL
`https://github.com/mdata-group/google-mlkit-swiftpm`.

> **Upgrading from `alex-pan-invos/...simfix1`?** The repo was transferred to
> `mdata-group` and the release assets moved with it. `9.0.0-simfix1` still
> resolves through GitHub's redirect, but you should repoint at
> `https://github.com/mdata-group/google-mlkit-swiftpm` `exact: "9.0.0-simfix2"`,
> whose `binaryTarget` URLs are canonical (no redirect) and self-contained.

### 2. Add the ML Kit modules you need to your target

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "MLKitBarcodeScanning", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitFaceDetection", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitTextRecognition", package: "google-mlkit-swiftpm"),
        // Also available: MLKitTextRecognitionChinese, MLKitTextRecognitionDevanagari,
        //                  MLKitTextRecognitionJapanese, MLKitTextRecognitionKorean
        .product(name: "MLKitImageLabeling", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitObjectDetection", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitPoseDetection", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitSegmentationSelfie", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitLanguageID", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitTranslate", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitSmartReply", package: "google-mlkit-swiftpm"),
    ]
)
```

### 3. Add linker flags

Add these to **Other Linker Flags** in your target's Build Settings, otherwise
you crash at runtime with `unrecognized selector`:

- `-ObjC`
- `-all_load`

### 4. Link resource bundles (required for Face Detection and Text Recognition)

Some ML Kit modules need runtime resource bundles. SwiftPM cannot copy loose
`.bundle`s into a consumer's app automatically, so these ship as **separate
`.zip` assets on the GitHub Release** and you must add them to your app target's
**Copy Bundle Resources** manually.

#### Face Detection

`MLKitFaceDetection` requires `GoogleMVFaceDetectorResources.bundle`. Download it
from the release and add it to your Xcode target:

```
https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/GoogleMVFaceDetectorResources.bundle.zip
```

#### Text Recognition ⚠️ (fork-specific — see [`9.0.0-textfix5`](#900-textfix5--text-recognition-crash-fix))

`MLKitTextRecognition` (and the CJK variants) need the OCR **model** bundle for
each language you use. Download the bundle(s) you use and add them to **Copy
Bundle Resources**, exactly like the Face Detection bundle:

| Product | Bundle to add |
|---|---|
| `MLKitTextRecognition` (Latin) | `LatinOCRResources.bundle.zip` |
| `MLKitTextRecognitionChinese` | `ChineseOCRResources.bundle.zip` |
| `MLKitTextRecognitionJapanese` | `JapaneseOCRResources.bundle.zip` |
| `MLKitTextRecognitionKorean` | `KoreanOCRResources.bundle.zip` |
| `MLKitTextRecognitionDevanagari` | `DevanagariOCRResources.bundle.zip` |

```
https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/LatinOCRResources.bundle.zip
```

**If you skip this**, `TextRecognizer(options:)` throws
`MLKTextRecognizerInternalErrorCreationFailure` with `"Invalid model path."` the
first time you try to recognize text. See the fork-patch write-up below for why
the model does not ride along inside the framework.

## Fork patches

Everything above the stock upstream `9.0.0` build. Read this before upgrading the
underlying ML Kit version — reproducing these patches is a manual step.

### `9.0.0-textfix5` — Text Recognition crash fix

**Symptom.** Two distinct runtime failures on stock upstream `9.0.0` / `9.0.0-1`:

1. `TextRecognizer(options:)` throws `MLKTextRecognizerInternalErrorCreationFailure`
   `"Invalid model path."` at construction — the OCR model files were never shipped.
2. Even after shipping the model, Release/Archive/TestFlight builds crashed at
   launch with `dyld: symbol not found in flat namespace '_MLKMillisecondsPerSecond'`
   (Debug builds worked, which masked the bug).

**Root cause.**

- Upstream's `9.0.0` release leaves the Latin OCR model out entirely.
  `MLKitTextRecognition.xcframework` ships without `LatinOCRResources.bundle`, so
  the recognizer has no model to load.
- `MLKitTextRecognitionCommon` ships as a single Mach-O **object file**. Upstream's
  pipeline relinked it into a *dynamic* framework, which dead-strips the OCR engine
  (60 MB → 38 KB) and externalizes ~711 ML Kit symbols (`_MLKMillisecondsPerSecond`,
  `_MLKLog`, …) to flat-namespace runtime lookup. Those symbols live in the
  *statically*-linked `MLKitCommon`, whose symbol table is stripped from the app's
  dynamic symbol table in Release/Archive builds — so `dyld` halts at launch.
  Debug builds don't strip, which is why it "worked on my machine".

**How it was fixed (and the iterations that got there).** This landed after
several tries — the earlier tags are kept for history, but only the final approach
(shipped as `9.0.0-textfix5`) is correct:

| Tag | Attempt | Outcome |
|---|---|---|
| `9.0.0-textfix1` | Embed `LatinOCRResources.bundle` into `MLKitTextRecognition.framework` + relink `Common` as a dynamic dylib (`ld -undefined dynamic_lookup`). | Model found in Debug, but wrong host framework and the dynamic dylib caused the flat-namespace crash in Release. |
| `9.0.0-textfix2` | Re-zip without `__MACOSX`/AppleDouble cruft; new tag so SwiftPM's URL-keyed download cache re-fetches. | Packaging cleanup only. |
| `9.0.0-textfix3` / `-textfix4` | Move the bundle **into `MLKitTextRecognitionCommon.framework`** (the framework whose class resolves the model via `bundleForClass:`, where `-[MLKTextRecognizer initWithLogger:options:]` runs). `textfix4` also corrected `MinimumOSVersion 12.0 → 15.5` to clear App Store `ITMS-90208`. | `"Invalid model path."` gone — but still a dynamic framework, so the flat-namespace Release crash remained. |
| **`9.0.0-textfix5`** | **Final.** Convert `MLKitTextRecognitionCommon` to a **static `ar` archive** (`mv → ar r → ranlib`, both slices) like the other static modules, so SwiftPM links it statically and every symbol resolves at *link* time against `MLKitCommon` in the same binary — no dynamic framework, no flat namespace, no dead-strip. Ship the per-language OCR models as **separate `*OCRResources.bundle.zip` release assets** (mirroring `GoogleMVFaceDetectorResources.bundle`) instead of embedding them. | ✅ `TextRecognizer` constructs; Release/TestFlight launches cleanly. Consumers add the OCR bundle to their app target (see [Installation §4](#4-link-resource-bundles-required-for-face-detection-and-text-recognition)). |

**What this means for the build pipeline.** The `9.0.0-textfix5` approach is now
encoded directly in the `Makefile`, so a rebuild reproduces it automatically as
long as these blocks survive an upgrade:

- `archive` target — the `ar r` / `ranlib` block that converts
  `MLKitTextRecognitionCommon` to a static archive in **both** the `ios-arm64` and
  the `ios-*-simulator` slices.
- `copy-resource-bundle` target — extracts each `*OCRResources.bundle` from the
  downloaded pod, and the `archive` target zips them as standalone release assets.

Refs: `d-date/google-mlkit-swiftpm#106`.

### `9.0.0-simfix2` — arm64 iOS Simulator support

**Symptom.** On Apple Silicon Macs with Xcode 26/27 (which dropped the
x86_64/Rosetta simulator runtimes), the stock ML Kit binaries have **no runnable
simulator slice** — they ship `arm64` for device and `x86_64` for simulator only,
and there is no longer an x86_64 simulator to run. You cannot build or run the app
in the simulator at all.

**Root cause.** Google ML Kit's pre-built binaries contain no `arm64`
iOS-Simulator slice, and Google does not publish one.

**How it was fixed.** `9.0.0-simfix2` builds on top of `9.0.0-textfix5` and
**synthesizes** the missing `arm64` simulator slice instead of waiting on Google:

- **`scripts/patch_arm64_sim.sh`** takes the built xcframeworks and, for every
  proprietary MLKit module, retargets the `arm64` **device** binary's Mach-O
  `LC_BUILD_VERSION` platform field from `2` (IOS) to `7` (IOSSIMULATOR), then
  `lipo`-merges the retargeted slice with the existing `x86_64` simulator slice.
  For static-archive modules it explodes the archive, patches each `.o`, and
  re-`libtool`s. It uses `vtool` where possible and falls back to a `python3`
  in-place `LC_BUILD_VERSION` byte-patch for the object files that `vtool` rejects
  under Xcode 26/27. `GoogleToolboxForMac` and `SSZipArchive` already ship a
  universal simulator slice and are passed through untouched. Technique adapted
  (CocoaPods → SwiftPM) from
  [`iwater/google-mlkit-ios-arm64-simulator`](https://github.com/iwater/google-mlkit-ios-arm64-simulator).
- **`Sources/MLKitAbseilStubs`** is an ObjC++ target compiled **only** for
  `TARGET_OS_SIMULATOR && __arm64__`. The platform-retargeted device slice
  references renamed abseil-logging internals (`MLKITx_absl…`) that
  `GoogleUtilities` does not provide; these stubs satisfy them so the simulator
  link succeeds. (`GULOSLog*` are intentionally **not** stubbed — `GoogleUtilities`
  already defines them, and duplicating causes a duplicate-symbol link error.)
  It is wired into the `Common` target's dependencies, so every product picks it up
  transitively on the simulator and it compiles to nothing on device / other archs.
- **`Package.swift`** proprietary `binaryTarget`s point at the `9.0.0-simfix2`
  release zips (each now carrying `ios-arm64` device + `ios-arm64_x86_64-simulator`).

`9.0.0-simfix1` was the first cut of this work (assets on the `alex-pan-invos`
account); `9.0.0-simfix2` repoints all 30 `binaryTarget` URLs at the canonical
`mdata-group` repo with its own attached assets. Binary bytes and checksums are
identical between the two — only the URLs changed.

## Supported features

### Vision APIs
- **Barcode Scanning** — scan and decode barcodes
- **Text Recognition** — recognize text in images (v2) with variants for Chinese, Devanagari, Japanese, and Korean
- **Face Detection** — detect faces and facial features
- **Image Labeling** — identify objects, locations, activities, and more (standard and custom models)
- **Object Detection & Tracking** — detect and track objects in images and video (standard and custom models)
- **Pose Detection** — detect body poses and positions (standard and accurate)
- **Selfie Segmentation** — segment people from the background

### Language APIs
- **Language Identification** — identify the language of text
- **Translation** — translate text between languages
- **Smart Reply** — generate contextual reply suggestions

## Limitations

- **Upstream `d-date` / stock ML Kit** builds `arm64` for iOS device and `x86_64`
  for the simulator only, so they cannot run in the simulator on Apple Silicon.
  **This fork's `9.0.0-simfix2` removes that limitation** by injecting an `arm64`
  simulator slice (see [`9.0.0-simfix2`](#900-simfix2--arm64-ios-simulator-support)).
  The injected slice is a *retargeted device binary*: it is correct for building and
  running in the simulator, but it is not a Google-produced simulator build — treat
  device as the source of truth for final validation.

## Example

Open `Example/Example.xcworkspace` and set code signing to yours. With
`9.0.0-simfix2` you can run it on an Apple Silicon simulator; otherwise run on a
real device.

## Upgrading the underlying ML Kit version (maintainers)

When Google ships a new ML Kit version, the fork patches are **not** automatic —
the text-recognition changes are encoded in the `Makefile` and reproduce on
rebuild, but the arm64-simulator injection is a separate manual pass. Follow this
end-to-end so the new release keeps **both** patches.

> Prerequisites: `git submodule update --init` (for `xcframework-maker/`), the
> pinned Ruby from `.tool-versions`, Xcode, and `gh` authenticated against the
> `mdata-group` repo. See `CLAUDE.md` / `AUTOMATION.md` for the pipeline internals.

### A. Rebuild the frameworks (reproduces `9.0.0-textfix5` automatically)

1. **Bump the version.** `ruby scripts/update_version.rb <new-version>` rewrites
   the `Podfile` pod versions and `CFBundleShortVersionString` in every
   `Resources/*-Info.plist`.
2. **Sanity-check the `Makefile` patch blocks survived** the version bump (they
   are the whole `9.0.0-textfix5` fix):
   - the `archive` target still runs `mv → ar r → ranlib` on
     **`MLKitTextRecognitionCommon`** in *both* the `ios-arm64` and
     `ios-*-simulator` framework slices (converts it to a static archive so it
     links statically — no flat-namespace crash);
   - the `copy-resource-bundle` target still extracts every `*OCRResources`
     bundle, and the `archive` target still zips `LatinOCRResources.bundle.zip`
     (+ Chinese/Japanese/Korean/Devanagari) as standalone assets.
3. **Build.** `make run` (or `./scripts/build_all.sh <new-version>`, which also
   recomputes checksums and rewrites `Package.swift`). Output lands in
   `GoogleMLKit/` as `arm64` device + `x86_64` simulator xcframeworks, with
   `MLKitTextRecognitionCommon` already a static archive and the OCR bundles
   extracted.

### B. Inject the arm64 simulator slice (reproduces `9.0.0-simfix2`)

4. **Patch.** Run the standalone patcher over the freshly built xcframeworks:

   ```bash
   ./scripts/patch_arm64_sim.sh GoogleMLKit GoogleMLKit-arm64sim
   ```

   It emits patched xcframeworks (each with `ios-arm64` device +
   `ios-arm64_x86_64-simulator`) into `GoogleMLKit-arm64sim/`. Watch the log — any
   module reporting `WARN some objects lacked LC_BUILD_VERSION` or
   `create-xcframework FAILED` needs investigation before you ship.
5. **Swap the patched xcframeworks back in** over `GoogleMLKit/` (keep the OCR /
   Face bundles, which the patcher passes through / does not touch), then **re-zip**
   every `*.xcframework` (plain `zip -X -y -r`, not `ditto`, to avoid `__MACOSX`
   cruft) alongside the bundle zips.
6. **Keep the SwiftPM wiring for the simulator stubs.** In `Package.swift`, the
   `MLKitAbseilStubs` target and the `Common` target's dependency on it must
   remain (they are what let the retargeted simulator slices link). If you regen
   `Package.swift` from a template, re-add them. Confirm the text-recognition
   products still list `MLKitTextRecognitionCommon` among their targets.

### C. Release and repoint

7. **Create the release + upload assets:**

   ```bash
   ./scripts/create_release.sh <new-version>-simfixN     # or: gh release create <tag>
   ./scripts/upload_release.sh <new-version>-simfixN     # uploads GoogleMLKit/*.zip
   ```

   Ship a **fresh pre-release tag** (`-simfixN`, incrementing `N`) rather than
   re-cutting an existing one — SwiftPM caches release zips by URL, so reusing a
   tag can serve stale assets to consumers.
8. **Rewrite `Package.swift` URLs + checksums** to the new tag on the
   `mdata-group` repo:

   ```bash
   ruby scripts/update_checksums_from_release.rb <new-version>-simfixN
   # (or scripts/update_checksums.rb against the local GoogleMLKit/ zips)
   ```

   Every `binaryTarget(url:)` must point at
   `https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/<tag>/…`
   (no redirect from an old account), with the recomputed SHA256.

### D. Verify before consumers pin it

9. `swift package dump-package` parses (CI runs this too).
10. Build **`Example/`** on an **Apple Silicon simulator** (proves the arm64 sim
    slice + abseil stubs link) *and* on a device.
11. Exercise **Text Recognition** end-to-end with the OCR bundle added to the
    Example target — confirm no `"Invalid model path."` and, in a **Release**
    build, no `symbol not found in flat namespace` at launch. These are the two
    regressions `9.0.0-textfix5` fixes and the ones most likely to reappear.
12. Bump the consumer pin (e.g. the iOS app's Xcode package reference) to
    `https://github.com/mdata-group/google-mlkit-swiftpm` `exact: "<new-version>-simfixN"`,
    and update the OCR / Face bundle download URLs in the app to the new tag.

## Automation

This repository includes automation for updating to new ML Kit versions:

- **Automated version checking** — daily GitHub Actions cron that opens an issue when CocoaPods has a newer version.
- **Build automation** — `scripts/build_all.sh` / `scripts/batch_build.sh`.
- **GitHub Actions** — the **Build MLKit XCFrameworks** workflow (manual `workflow_dispatch`).

For details see [AUTOMATION.md](AUTOMATION.md), [CLAUDE.md](CLAUDE.md) (pipeline
shape + gotchas), and `scripts/README.md`.

> ⚠️ The automation rebuilds the **upstream** shape. It reproduces
> `9.0.0-textfix5` (encoded in the `Makefile`) but **not** the `9.0.0-simfix2`
> arm64-simulator injection — that is the manual Step B above. Don't ship an
> automated build to simulator consumers without re-running `patch_arm64_sim.sh`.
