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

class ApiErrorItemTestCase: XCTestCase {

    func testDecodingWithAllProperties() {
        let apiErrorItemJson = Data(
            """
            {
                "errorCode": "123456",
                "category": "PAYMENT_PLATFORM_ERROR",
                "httpStatusCode": 404,
                "id": "1",
                "message": "The product could not be found",
                "propertyName": "productId",
                "retriable": false
            }
            """.utf8
        )

        guard let apiErrorItem = try? JSONDecoder().decode(ApiErrorItem.self, from: apiErrorItemJson) else {
            XCTFail("ApiErrorItem could not be decoded")
            return
        }

        XCTAssertEqual(apiErrorItem.errorCode, "123456")
        XCTAssertEqual(apiErrorItem.category, "PAYMENT_PLATFORM_ERROR")
        XCTAssertEqual(apiErrorItem.httpStatusCode, 404)
        XCTAssertEqual(apiErrorItem.id, "1")
        XCTAssertEqual(apiErrorItem.message, "The product could not be found")
        XCTAssertEqual(apiErrorItem.propertyName, "productId")
        XCTAssertFalse(apiErrorItem.retriable)
    }

    func testDecodingWithMissingOptionalProperties() {
        let apiErrorItemJson = Data(
            """
            {
                "errorCode": "123456"
            }
            """.utf8
        )

        guard let apiErrorItem = try? JSONDecoder().decode(ApiErrorItem.self, from: apiErrorItemJson) else {
            XCTFail("ApiErrorItem could not be decoded")
            return
        }

        XCTAssertEqual(apiErrorItem.errorCode, "123456")
        XCTAssertNil(apiErrorItem.category)
        XCTAssertNil(apiErrorItem.httpStatusCode)
        XCTAssertNil(apiErrorItem.id)
        XCTAssertEqual(apiErrorItem.message, "This error does not contain a message")
        XCTAssertNil(apiErrorItem.propertyName)
        XCTAssertTrue(apiErrorItem.retriable)
    }
}
