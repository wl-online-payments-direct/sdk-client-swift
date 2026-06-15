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

final class ValidatorTermsAndConditionsTestCase: XCTestCase {

    private let validator = ValidatorTermsAndConditions()

    // MARK: - CSV Tests

    func testValidateReturnsTrueForStringTrue() {
        let result = validator.validate(value: "true")

        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")
    }

    func testValidateReturnsFalseForStringFalse() {
        let result = validator.validate(value: "false")

        XCTAssertFalse(result.valid)
    }

    func testValidateReturnsFalseForOtherStrings() {
        XCTAssertFalse(validator.validate(value: "yes").valid)
        XCTAssertFalse(validator.validate(value: "1").valid)
        XCTAssertFalse(validator.validate(value: "").valid)
    }
}
