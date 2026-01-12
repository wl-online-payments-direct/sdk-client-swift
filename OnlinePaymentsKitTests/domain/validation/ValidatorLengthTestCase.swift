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

final class ValidatorLengthTestCase: XCTestCase {

    private func createValidator(minLength: Int?, maxLength: Int?) -> ValidatorLength {
        return ValidatorLength(minLength: minLength, maxLength: maxLength)
    }

    func testValidateValuesWithinMinMaxLength() {
        let validator = createValidator(minLength: 3, maxLength: 10)

        var result = validator.validate(value: "abc")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")

        result = validator.validate(value: "12345")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")

        result = validator.validate(value: "1234567890")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")
    }

    func testRejectValuesTooShort() {
        let validator = createValidator(minLength: 3, maxLength: 10)

        var result = validator.validate(value: "ab")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Provided value does not have an allowed length.")

        result = validator.validate(value: "a")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Provided value does not have an allowed length.")

        result = validator.validate(value: "")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Provided value does not have an allowed length.")
    }

    func testRejectValuesTooLong() {
        let validator = createValidator(minLength: 3, maxLength: 10)

        var result = validator.validate(value: "12345678901")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Provided value does not have an allowed length.")

        result = validator.validate(value: "123456789012345")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Provided value does not have an allowed length.")
    }

    func testValidateExactlyMinLength() {
        let validator = createValidator(minLength: 5, maxLength: 10)

        let result = validator.validate(value: "12345")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")
    }

    func testValidateExactlyMaxLength() {
        let validator = createValidator(minLength: 5, maxLength: 10)

        let result = validator.validate(value: "1234567890")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")
    }
}
