/*
 * Do not remove or alter the notices in this preamble.
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
