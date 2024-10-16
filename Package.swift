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
            url: "https://github.com/carrotquest/ios-sdk/raw/refs/heads/beta/CarrotSDK.xcframework.zip",
            checksum: "730038bd74a6bed2fb1d0fe1b6830ba0a35759dc3e7722a4d3cd5cf2677bfccc"
        ),
    ]
)