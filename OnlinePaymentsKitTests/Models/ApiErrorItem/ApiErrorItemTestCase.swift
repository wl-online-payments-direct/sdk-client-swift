//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 17/05/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
//

import XCTest
@testable import OnlinePaymentsKit

class ApiErrorItemTestCase: XCTestCase {

    func testDecodingWithAllProperties() {
        let apiErrorItemJson = Data("""
        {
            "errorCode": "123456",
            "category": "PAYMENT_PLATFORM_ERROR",
            "code": "123456",
            "httpStatusCode": 404,
            "id": "1",
            "message": "The product could not be found",
            "propertyName": "productId",
            "retriable": false
        }
        """.utf8)

        guard let apiErrorItem = try? JSONDecoder().decode(ApiErrorItem.self, from: apiErrorItemJson) else {
            XCTFail("ApiErrorItem could not be decoded")
            return
        }

        XCTAssertEqual(apiErrorItem.errorCode, "123456")
        XCTAssertEqual(apiErrorItem.category, "PAYMENT_PLATFORM_ERROR")
        XCTAssertEqual(apiErrorItem.code, "123456")
        XCTAssertEqual(apiErrorItem.httpStatusCode, 404)
        XCTAssertEqual(apiErrorItem.id, "1")
        XCTAssertEqual(apiErrorItem.message, "The product could not be found")
        XCTAssertEqual(apiErrorItem.propertyName, "productId")
        XCTAssertFalse(apiErrorItem.retriable)
    }

    func testDecodingWithMissingOptionalProperties() {
        let apiErrorItemJson = Data("""
        {
            "errorCode": "123456"
        }
        """.utf8)

        guard let apiErrorItem = try? JSONDecoder().decode(ApiErrorItem.self, from: apiErrorItemJson) else {
            XCTFail("ApiErrorItem could not be decoded")
            return
        }

        XCTAssertEqual(apiErrorItem.errorCode, "123456")
        XCTAssertNil(apiErrorItem.category)
        XCTAssertEqual(apiErrorItem.code, "This error does not contain a code")
        XCTAssertNil(apiErrorItem.httpStatusCode)
        XCTAssertNil(apiErrorItem.id)
        XCTAssertEqual(apiErrorItem.message, "This error does not contain a message")
        XCTAssertNil(apiErrorItem.propertyName)
        XCTAssertTrue(apiErrorItem.retriable)
    }
}
