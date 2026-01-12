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

final class ValidatorEmailAddressTestCase: XCTestCase {

    private let validator = ValidatorEmailAddress()

    func testValidateCorrectEmailAddresses() {
        var result = validator.validate(value: "test@example.com")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")

        result = validator.validate(value: "user.name@example.com")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")

        result = validator.validate(value: "user+tag@example.co.uk")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")
    }

    func testRejectInvalidEmailAddresses() {
        var result = validator.validate(value: "invalid")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Email address is not in the correct format.")

        result = validator.validate(value: "@example.com")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Email address is not in the correct format.")

        result = validator.validate(value: "user@")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Email address is not in the correct format.")

        result = validator.validate(value: "user@.com")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Email address is not in the correct format.")
    }
}
