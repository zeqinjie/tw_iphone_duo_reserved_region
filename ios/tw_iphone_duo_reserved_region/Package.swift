// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tw_iphone_duo_reserved_region",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "tw-iphone-duo-reserved-region",
            targets: ["tw_iphone_duo_reserved_region"]
        )
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "tw_iphone_duo_reserved_region",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            cSettings: [
                .headerSearchPath("include/tw_iphone_duo_reserved_region")
            ]
        )
    ]
)
