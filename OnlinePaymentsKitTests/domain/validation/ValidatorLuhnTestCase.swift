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

final class ValidatorLuhnTestCase: XCTestCase {

    private let validator = ValidatorLuhn()

    func testValidateCorrectCardNumbers() {
        let result = validator.validate(value: "4242424242424242")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")
    }

    func testRejectInvalidCardNumbers() {
        let result = validator.validate(value: "1111")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Card number is in invalid format.")
    }
}
