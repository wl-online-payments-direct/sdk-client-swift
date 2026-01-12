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

final class ValidatorFixedListTestCase: XCTestCase {

    private func createValidator(allowedValues: [String]) -> ValidatorFixedList {
        return ValidatorFixedList(allowedValues: allowedValues)
    }

    func testValidateValueThatIsInTheAllowedList() {
        let validator = createValidator(allowedValues: ["visa", "mastercard", "amex"])

        var result = validator.validate(value: "visa")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")

        result = validator.validate(value: "mastercard")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")

        result = validator.validate(value: "amex")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")
    }

    func testRejectValueThatIsNotInTheAllowedList() {
        let validator = createValidator(allowedValues: ["visa", "mastercard", "amex"])

        var result = validator.validate(value: "discover")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Provided value is not allowed.")

        result = validator.validate(value: "jcb")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Provided value is not allowed.")
    }

    func testHandleEmptyAllowedValuesList() {
        let validator = createValidator(allowedValues: [])

        let result = validator.validate(value: "anything")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Provided value is not allowed.")
    }
}
