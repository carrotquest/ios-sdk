// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CarrotSDKbeta",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "CarrotSDKbeta",
            targets: ["CarrotSDK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "CarrotSDKbeta",
            url: "https://github.com/carrotquest/ios-sdk/blob/beta/CarrotSDK.xcframework.zip",
            checksum: "730038bd74a6bed2fb1d0fe1b6830ba0a35759dc3e7722a4d3cd5cf2677bfccc"
    ]
)