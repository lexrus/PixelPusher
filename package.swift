// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "PixelPusher",
    products: [
        .library(name: "PixelPusher", targets: ["PixelPusher"])
    ],
    targets: [
        .target(
            name: "PixelPusher",
            path: "PixelPusher"
        )
    ]
)