// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TimeSecondsDisplayer",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "TimeSecondsDisplayer", targets: ["TimeSecondsDisplayer"]),
        .library(name: "TimeSecondsWidget", targets: ["TimeSecondsWidget"]),
    ],
    targets: [
        .target(name: "TimeSecondsDisplayer"),
        .target(name: "TimeSecondsWidget"),
    ]
)
