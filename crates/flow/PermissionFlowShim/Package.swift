// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PermissionFlowShim",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PermissionFlowShimFFI",
            type: .static,
            targets: ["PermissionFlowShimFFI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/brendonovich/swift-rs", from: "1.0.6"),
        .package(path: "../PermissionFlow")
    ],
    targets: [
        .target(
            name: "PermissionFlowShimFFI",
            dependencies: [
                .product(name: "SwiftRs", package: "swift-rs"),
                "PermissionFlow"
            ]
        )
    ]
)
