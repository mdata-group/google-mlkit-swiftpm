// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "GoogleMLKitSwiftPM",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "MLKitBarcodeScanning",
            targets: ["MLKitBarcodeScanning", "MLImage", "MLKitVision", "Common"]
        ),
        .library(
            name: "MLKitFaceDetection",
            targets: ["MLKitFaceDetection", "MLImage", "MLKitVision", "Common"]
        ),
        .library(
            name: "MLKitTextRecognition",
            targets: ["MLKitTextRecognition", "MLKitTextRecognitionCommon", "MLImage", "MLKitVision", "Common"]
        ),
        .library(
            name: "MLKitTextRecognitionChinese",
            targets: ["MLKitTextRecognitionChinese", "MLKitTextRecognitionCommon", "MLImage", "MLKitVision", "Common"]
        ),
        .library(
            name: "MLKitTextRecognitionDevanagari",
            targets: ["MLKitTextRecognitionDevanagari", "MLKitTextRecognitionCommon", "MLImage", "MLKitVision", "Common"]
        ),
        .library(
            name: "MLKitTextRecognitionJapanese",
            targets: ["MLKitTextRecognitionJapanese", "MLKitTextRecognitionCommon", "MLImage", "MLKitVision", "Common"]
        ),
        .library(
            name: "MLKitTextRecognitionKorean",
            targets: ["MLKitTextRecognitionKorean", "MLKitTextRecognitionCommon", "MLImage", "MLKitVision", "Common"]
        ),
        .library(
            name: "MLKitImageLabeling",
            targets: ["MLKitImageLabeling", "MLKitImageLabelingCommon", "MLKitVisionKit", "MLImage", "MLKitVision", "Common"]
        ),
        .library(
            name: "MLKitImageLabelingCustom",
            targets: ["MLKitImageLabelingCustom", "MLKitImageLabelingCommon", "MLImage", "MLKitVision", "Common"]
        ),
        .library(
            name: "MLKitObjectDetection",
            targets: ["MLKitObjectDetection", "MLKitObjectDetectionCommon", "MLImage", "MLKitVision", "Common"]
        ),
        .library(
            name: "MLKitObjectDetectionCustom",
            targets: ["MLKitObjectDetectionCustom", "MLKitObjectDetectionCommon", "MLImage", "MLKitVision", "Common"]
        ),
        .library(
            name: "MLKitPoseDetection",
            targets: ["MLKitPoseDetection", "MLKitPoseDetectionCommon", "MLImage", "MLKitVision", "Common"]
        ),
        .library(
            name: "MLKitPoseDetectionAccurate",
            targets: ["MLKitPoseDetectionAccurate", "MLKitPoseDetectionCommon", "MLImage", "MLKitVision", "Common"]
        ),
        .library(
            name: "MLKitSegmentationSelfie",
            targets: ["MLKitSegmentationSelfie", "MLKitSegmentationCommon", "MLImage", "MLKitVision", "Common"]
        ),
        .library(
            name: "MLKitLanguageID",
            targets: ["MLKitLanguageID", "MLKitNaturalLanguage", "MLKitXenoCommon", "MLKitCommon", "GoogleToolboxForMac", "Common"]
        ),
        .library(
            name: "MLKitTranslate",
            targets: ["MLKitTranslate", "SSZipArchive", "MLKitNaturalLanguage", "MLKitXenoCommon", "MLKitCommon", "GoogleToolboxForMac", "Common"]
        ),
        .library(
            name: "MLKitSmartReply",
            targets: ["MLKitSmartReply", "MLKitLanguageID", "MLKitNaturalLanguage", "MLKitXenoCommon", "MLKitCommon", "GoogleToolboxForMac", "Common"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/google/promises.git", exact: "2.4.0"),
        .package(url: "https://github.com/google/GoogleDataTransport.git", exact: "10.1.0"),
        .package(url: "https://github.com/google/GoogleUtilities.git", exact: "8.1.0"),
        .package(url: "https://github.com/google/gtm-session-fetcher.git", exact: "3.5.0"),
        .package(url: "https://github.com/firebase/nanopb.git", exact: "2.30910.0"),
    ],
    targets: [
        // For debugging
        // .binaryTarget(
        //   name: "MLImage",
        //   path: "GoogleMLKit/MLImage.xcframework"),
        // .binaryTarget(
        //   name: "MLKitBarcodeScanning",
        //   path: "GoogleMLKit/MLKitBarcodeScanning.xcframework"),
        // .binaryTarget(
        //   name: "MLKitCommon",
        //   path: "GoogleMLKit/MLKitCommon.xcframework"),
        // .binaryTarget(
        //   name: "MLKitFaceDetection",
        //   path: "GoogleMLKit/MLKitFaceDetection.xcframework"),
        // .binaryTarget(
        //   name: "MLKitVision",
        //   path: "GoogleMLKit/MLKitVision.xcframework"),
        // .binaryTarget(
        //   name: "GoogleToolboxForMac",
        //   path: "GoogleMLKit/GoogleToolboxForMac.xcframework"),
        // .binaryTarget(
        //   name: "MLKitTextRecognition",
        //   path: "GoogleMLKit/MLKitTextRecognition.xcframework"),
        // .binaryTarget(
        //   name: "MLKitTextRecognitionChinese",
        //   path: "GoogleMLKit/MLKitTextRecognitionChinese.xcframework"),
        // .binaryTarget(
        //   name: "MLKitTextRecognitionDevanagari",
        //   path: "GoogleMLKit/MLKitTextRecognitionDevanagari.xcframework"),
        // .binaryTarget(
        //   name: "MLKitTextRecognitionJapanese",
        //   path: "GoogleMLKit/MLKitTextRecognitionJapanese.xcframework"),
        // .binaryTarget(
        //   name: "MLKitTextRecognitionKorean",
        //   path: "GoogleMLKit/MLKitTextRecognitionKorean.xcframework"),
        // .binaryTarget(
        //   name: "MLKitImageLabeling",
        //   path: "GoogleMLKit/MLKitImageLabeling.xcframework"),
        // .binaryTarget(
        //   name: "MLKitImageLabelingCustom",
        //   path: "GoogleMLKit/MLKitImageLabelingCustom.xcframework"),
        // .binaryTarget(
        //   name: "MLKitObjectDetection",
        //   path: "GoogleMLKit/MLKitObjectDetection.xcframework"),
        // .binaryTarget(
        //   name: "MLKitObjectDetectionCustom",
        //   path: "GoogleMLKit/MLKitObjectDetectionCustom.xcframework"),
        // .binaryTarget(
        //   name: "MLKitPoseDetection",
        //   path: "GoogleMLKit/MLKitPoseDetection.xcframework"),
        // .binaryTarget(
        //   name: "MLKitPoseDetectionAccurate",
        //   path: "GoogleMLKit/MLKitPoseDetectionAccurate.xcframework"),
        // .binaryTarget(
        //   name: "MLKitSegmentationSelfie",
        //   path: "GoogleMLKit/MLKitSegmentationSelfie.xcframework"),
        // .binaryTarget(
        //   name: "MLKitLanguageID",
        //   path: "GoogleMLKit/MLKitLanguageID.xcframework"),
        // .binaryTarget(
        //   name: "MLKitTranslate",
        //   path: "GoogleMLKit/MLKitTranslate.xcframework"),
        // .binaryTarget(
        //   name: "MLKitSmartReply",
        //   path: "GoogleMLKit/MLKitSmartReply.xcframework"),

        .binaryTarget(
            name: "MLImage",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLImage.xcframework.zip",
            checksum: "b36d7a463d9b92f2a26f81d60466807ad32daefc643ea6da4c0521fc6d9b12a3"
        ),
        .binaryTarget(
            name: "MLKitBarcodeScanning",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitBarcodeScanning.xcframework.zip",
            checksum: "7dc1c3d69645ac367648713d17022448b4dd89d8250117dd7426d8eb57ae7d6f"
        ),
        .binaryTarget(
            name: "MLKitCommon",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitCommon.xcframework.zip",
            checksum: "c283013f4888a3bd298b6c64e78faf376a844944ab8e85568c92bc297d3e4a82"
        ),
        .binaryTarget(
            name: "MLKitFaceDetection",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitFaceDetection.xcframework.zip",
            checksum: "f4aeacb2633c0cf727f2d37c033b17eb53598783c57f063ddf5c239121da3f77"
        ),
        .binaryTarget(
            name: "MLKitVision",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitVision.xcframework.zip",
            checksum: "031bba088c27c5ef63df528e5df722fa9cc44011c14cc7f6415c60f2b419751a"
        ),
        .binaryTarget(
            name: "GoogleToolboxForMac",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/GoogleToolboxForMac.xcframework.zip",
            checksum: "0ffe7a585b36875b7eda993d1c1cdedeb55e5d0cafb66ddd45e5b341f658e0af"
        ),
        .binaryTarget(
            name: "MLKitTextRecognition",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitTextRecognition.xcframework.zip",
            checksum: "476bec658afefc8ecd1b628eea69576edef1a7800bd22a8a6bf264d8e1c78a5b"
        ),
        .binaryTarget(
            name: "MLKitTextRecognitionChinese",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitTextRecognitionChinese.xcframework.zip",
            checksum: "f032db593979b7717ceb28a2b1e0eb63d1d8ac1df8de24d58be1b90c51a3d3a7"
        ),
        .binaryTarget(
            name: "MLKitTextRecognitionDevanagari",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitTextRecognitionDevanagari.xcframework.zip",
            checksum: "d2a0e7b3d60e91111048c0e8b99bb7b6abf79d25fbf1b4e91409bbe0965240a8"
        ),
        .binaryTarget(
            name: "MLKitTextRecognitionJapanese",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitTextRecognitionJapanese.xcframework.zip",
            checksum: "3815f7e556683be3e13acefe2b4a2a7a0d0f7baf75f1c2e5fee346ff95f68dd6"
        ),
        .binaryTarget(
            name: "MLKitTextRecognitionKorean",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitTextRecognitionKorean.xcframework.zip",
            checksum: "8fe4929e46362da38f578345d61ec9651262978cc9cd798e2e728e4f1f216338"
        ),
        .binaryTarget(
            name: "MLKitImageLabeling",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitImageLabeling.xcframework.zip",
            checksum: "c922c0ed5a0a5ddedf65e1bedcbafd8038b0888aa034de9008f529213127c28e"
        ),
        .binaryTarget(
            name: "MLKitImageLabelingCustom",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitImageLabelingCustom.xcframework.zip",
            checksum: "9c01380c2fbccb5c91715651b1b9c770a5f198392f94af37be546ee42ed0e91d"
        ),
        .binaryTarget(
            name: "MLKitObjectDetection",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitObjectDetection.xcframework.zip",
            checksum: "ac38e3be311168dde254b1a50a254c6c91b8060b39cbc8ad9649e6f95c2ded9f"
        ),
        .binaryTarget(
            name: "MLKitObjectDetectionCustom",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitObjectDetectionCustom.xcframework.zip",
            checksum: "307a29330ed3b9217eacc1494866f8e7225ca0b8978fa97694887f1b70a7747e"
        ),
        .binaryTarget(
            name: "MLKitPoseDetection",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitPoseDetection.xcframework.zip",
            checksum: "08bb871cd79c89aa39f52500f974159fc8e9c47818da764097ee2b00f618efdd"
        ),
        .binaryTarget(
            name: "MLKitPoseDetectionAccurate",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitPoseDetectionAccurate.xcframework.zip",
            checksum: "17910ec95f352fd2d67e16e7bb78dfdf54e1c50b9ff54e30532ea565eaa5a8ef"
        ),
        .binaryTarget(
            name: "MLKitSegmentationSelfie",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitSegmentationSelfie.xcframework.zip",
            checksum: "f91d2ba2248fb3155e7c254201129015dff760fd4c35a27743d93d20a7aaf49c"
        ),
        .binaryTarget(
            name: "MLKitLanguageID",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitLanguageID.xcframework.zip",
            checksum: "1166bee4e3415c957b065e2659cc3223712ad29e22bc9f4f96c0b8071539c6b9"
        ),
        .binaryTarget(
            name: "MLKitTranslate",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitTranslate.xcframework.zip",
            checksum: "8f8e31bb3dbfccc4314ca8f4600cb103910a43500426a535e86002d3962c63a0"
        ),
        .binaryTarget(
            name: "MLKitSmartReply",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitSmartReply.xcframework.zip",
            checksum: "48cecbc6fc61658bd6092b2c7841f0b5a04111e98a47b5d32eb207fa6a1b1e1c"
        ),
        .binaryTarget(
            name: "MLKitVisionKit",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitVisionKit.xcframework.zip",
            checksum: "316a9725f6193210df6c037005611c3706f42521ac0bd580cdedb84798455a94"
        ),
        .binaryTarget(
            name: "MLKitImageLabelingCommon",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitImageLabelingCommon.xcframework.zip",
            checksum: "ed76f4688fe8a9a7e11dbe6d17599f3bda9de55415f124ab5ed8117790ba490d"
        ),
        .binaryTarget(
            name: "MLKitObjectDetectionCommon",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitObjectDetectionCommon.xcframework.zip",
            checksum: "fa26a2de2b29652825487e91815b513a2fb077642ce634ec9badea756ca16510"
        ),
        .binaryTarget(
            name: "MLKitPoseDetectionCommon",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitPoseDetectionCommon.xcframework.zip",
            checksum: "ac85d21946d190f91281504fd44071ec0352dfe98732ae6cdce268704a919ead"
        ),
        .binaryTarget(
            name: "MLKitSegmentationCommon",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitSegmentationCommon.xcframework.zip",
            checksum: "bda1f4b6f91967f19b00b0acdace2e52bbd380f94cb993f8c878d139155cb2ff"
        ),
        .binaryTarget(
            name: "MLKitTextRecognitionCommon",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitTextRecognitionCommon.xcframework.zip",
            checksum: "0ef7ede34ae5d29fa436946f63681fcf3b6babcbd70bd40b845dc797c6131b18"
        ),
        .binaryTarget(
            name: "MLKitXenoCommon",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitXenoCommon.xcframework.zip",
            checksum: "4d5b156f6e9434c58e384bc586e26e99ef39dc244017231e1d357c39c43c5fdb"
        ),
        .binaryTarget(
            name: "MLKitNaturalLanguage",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/MLKitNaturalLanguage.xcframework.zip",
            checksum: "b9681739c885d4f0813c07b3f04d02653592276a1096dbbea5a8e3d06d9923eb"
        ),
        .binaryTarget(
            name: "SSZipArchive",
            url: "https://github.com/mdata-group/google-mlkit-swiftpm/releases/download/9.0.0-simfix2/SSZipArchive.xcframework.zip",
            checksum: "7690306b01a057bb24fc4cf18b810c20f22d5fc3ed00f51e73cb97a7d7bcabab"
        ),
        .target(
            name: "Common",
            dependencies: [
                "MLKitAbseilStubs",
                "MLKitCommon",
                "GoogleToolboxForMac",
                .product(name: "GULAppDelegateSwizzler", package: "GoogleUtilities"),
                .product(name: "GULEnvironment", package: "GoogleUtilities"),
                .product(name: "GULLogger", package: "GoogleUtilities"),
                .product(name: "GULMethodSwizzler", package: "GoogleUtilities"),
                .product(name: "GULNSData", package: "GoogleUtilities"),
                .product(name: "GULNetwork", package: "GoogleUtilities"),
                .product(name: "GULReachability", package: "GoogleUtilities"),
                .product(name: "GULUserDefaults", package: "GoogleUtilities"),
                .product(name: "GTMSessionFetcher", package: "gtm-session-fetcher"),
                .product(name: "GoogleDataTransport", package: "GoogleDataTransport"),
                .product(name: "nanopb", package: "nanopb"),
                .product(name: "FBLPromises", package: "promises"),
            ]
        ),
        .target(
            name: "MLKitAbseilStubs",
            path: "Sources/MLKitAbseilStubs"
        ),
    ]
)
