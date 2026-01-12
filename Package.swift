// swift-tools-version:5.5
/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

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
