// swift-tools-version:5.3
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//
import Foundation
import PackageDescription

let package = Package(
    name: "OnlinePaymentsKit",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "OnlinePaymentsKit",
            targets: ["OnlinePaymentsKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.6.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.5.0"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubsSwift", from: "9.1.0"),
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
            dependencies: ["OnlinePaymentsKit", "OHHTTPStubsSwift"],
            path: "OnlinePaymentsKitTests"
        )
    ]
)
