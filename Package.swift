// swift-tools-version:5.5
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2025 Global Collect Services. All rights reserved.
//
import Foundation
import PackageDescription

let package = Package(
    name: "OnlinePaymentsKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "OnlinePaymentsKit",
            targets: ["OnlinePaymentsKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.6.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.5.0"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs", from: "9.1.0")
    ],
    targets: [
        .target(
            name: "OnlinePaymentsKit",
            dependencies: ["Alamofire", "CryptoSwift"],
            path: "OnlinePaymentsKit",
            resources: [.copy("Resources/OnlinePaymentsKit.bundle")]
        ),
        .testTarget(
            name: "OnlinePaymentsKitTests",
            dependencies: ["OnlinePaymentsKit", "OHHTTPStubs"],
            path: "OnlinePaymentsKitTests"
        )
    ]
)
