// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TSKit.Injection",
    products: [
        .library(
            name: "TSKit.Injection",
            targets: ["TSKit.Injection"]),
    ],
    dependencies: [
        .package(url: "https://github.com/adya/TSKit.Core.git", .upToNextMajor(from: "2.3.0")),
        .package(url: "https://github.com/adya/TSKit.Log.git", .upToNextMajor(from: "2.3.0"))
        
    ],
    targets: [
        .target(
            name: "TSKit.Injection",
            dependencies: ["TSKit.Core", "TSKit.Log"]),
        .testTarget(
            name: "TSKit.InjectionTests",
            dependencies: ["TSKit.Injection"]),
    ]
)
