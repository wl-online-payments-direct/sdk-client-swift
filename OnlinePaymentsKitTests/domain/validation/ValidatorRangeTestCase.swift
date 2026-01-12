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

final class ValidatorRangeTestCase: XCTestCase {

    private func createValidator(minValue: Int, maxValue: Int) -> ValidatorRange {
        return ValidatorRange(minValue: minValue, maxValue: maxValue)
    }

    func testValidateNumericValuesWithinRange() {
        let validator = createValidator(minValue: 1, maxValue: 100)

        var result = validator.validate(value: "1")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")

        result = validator.validate(value: "50")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")

        result = validator.validate(value: "100")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")
    }

    func testRejectNumericValuesOutsideRange() {
        let validator = createValidator(minValue: 1, maxValue: 100)

        var result = validator.validate(value: "0")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Provided value must be between 1 and 100.")

        result = validator.validate(value: "101")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Provided value must be between 1 and 100.")

        result = validator.validate(value: "-5")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Provided value must be between 1 and 100.")
    }

    func testRejectNonNumericStrings() {
        let validator = createValidator(minValue: 1, maxValue: 100)

        let result = validator.validate(value: "abc")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Provided value is not a number.")
    }
}
