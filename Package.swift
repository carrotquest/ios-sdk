// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CarrotSDK",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "CarrotSDK",
            targets: ["CarrotSDK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "CarrotSDK",
            url: "https://github.com/carrotquest/ios-sdk/raw/refs/heads/master/CarrotSDK.xcframework.zip",
            checksum: "9ca863f0d36f27bcecb534101a64f389f318b10d091fd8bcee291773a682d9fe"
        ),
    ]
)