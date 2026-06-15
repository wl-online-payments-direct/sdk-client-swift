/*
 * Do not remove or alter the notices in this preamble.
 *
 * This software is owned by Worldline and may not be be altered, copied, reproduced, republished, uploaded, posted, transmitted or distributed in any way, without the prior written consent of Worldline.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import XCTest

@testable import OnlinePaymentsKit

class MetadataUtilTestCase: XCTestCase {

    let util = MetadataUtil.shared


    private func decodeMetaInfo(_ encoded: String) -> [String: String]? {
        let decoded = encoded.decode()

        return try? JSONSerialization.jsonObject(with: decoded, options: []) as? [String: String]
    }

    func testBase64EncodedClientMetaInfoIncludesProvidedAppIdentifier() {
        guard let encoded = util.base64EncodedClientMetaInfo(
            withAppIdentifier: "MyApp",
            addedData: nil,
            sdkIdentifier: "test-sdk"
        ), let meta = decodeMetaInfo(encoded) else {
            XCTFail("Could not decode meta info")

            return
        }

        XCTAssertEqual(meta["appIdentifier"], "MyApp")
        XCTAssertEqual(meta["sdkCreator"], "Online Payments")
    }

    func testBase64EncodedClientMetaInfoUsesUnknownWhenNoAppIdentifierProvided() {
        guard let encoded = util.base64EncodedClientMetaInfo(
            withAppIdentifier: nil,
            addedData: nil,
            sdkIdentifier: "test-sdk"
        ), let meta = decodeMetaInfo(encoded) else {
            XCTFail("Could not decode meta info")

            return
        }

        XCTAssertEqual(meta["appIdentifier"], "UNKNOWN")
    }

    func testBase64EncodedClientMetaInfoIncludesSdkIdentifier() {
        let customIdentifier = "SwiftSDK/1.0.0"
        guard let encoded = util.base64EncodedClientMetaInfo(
            withAppIdentifier: nil,
            addedData: nil,
            sdkIdentifier: customIdentifier
        ), let meta = decodeMetaInfo(encoded) else {
            XCTFail("Could not decode meta info")

            return
        }

        XCTAssertEqual(meta["sdkIdentifier"], customIdentifier)
    }

    func testBase64EncodedClientMetaInfoIncludesDeviceMetadata() {
        guard let encoded = util.base64EncodedClientMetaInfo(
            withAppIdentifier: nil,
            addedData: nil,
            sdkIdentifier: "test"
        ), let meta = decodeMetaInfo(encoded) else {
            XCTFail("Could not decode meta info")

            return
        }

        XCTAssertNotNil(meta["platformIdentifier"])
        XCTAssertNotNil(meta["screenSize"])
        XCTAssertEqual(meta["deviceBrand"], "Apple")
        XCTAssertNotNil(meta["deviceType"])
    }

    func testBase64UrlEncodeReturnsUrlSafeBase64WithoutPadding() {
        // bytes 0xFF and 0xFB produce "+/" in standard base64 → "-_" in URL-safe, with no "=" padding
        let data = Data([0xFF, 0xFB])
        let result = data.base64URLEncode()

        XCTAssertFalse(result.contains("="), "URL-safe base64 should strip padding")
        XCTAssertFalse(result.contains("+"), "URL-safe base64 should replace + with -")
        XCTAssertFalse(result.contains("/"), "URL-safe base64 should replace / with _")
    }

    func testBase64EncodedClientMetaInfo() {
        if let info = util.base64EncodedClientMetaInfo {
            let decodedInfo = info.decode()

            guard
                let JSON =
                    try? JSONSerialization.jsonObject(with: decodedInfo, options: []) as? [String: String]
            else {
                XCTFail("Could not deserialize JSON")

                return
            }

            XCTAssertEqual(JSON["deviceBrand"], "Apple", "Incorrect device brand in meta info")
            XCTAssert(
                JSON["deviceType"] == "arm64" || JSON["deviceType"] == "x86_64",
                "Incorrect device type in meta info"
            )
        }
    }

    func testBase64EncodedClientMetaInfoWithAddedData() {
        if let info = util.base64EncodedClientMetaInfo(withAddedData: ["test": "value"]) {
            let decodedInfo = info.decode()

            guard
                let JSON =
                    try? JSONSerialization.jsonObject(with: decodedInfo, options: []) as? [String: String]
            else {
                XCTFail("Could not deserialize JSON")

                return
            }

            XCTAssertEqual(JSON["test"], "value", "Incorrect value for added key in meta info")
        }
    }
}
