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

final class ValidatorRegularExpressionTestCase: XCTestCase {

    private var validator: ValidatorRegularExpression!

    override func setUp() {
        super.setUp()

        let regularExpression: NSRegularExpression
        do {
            regularExpression = try NSRegularExpression(pattern: "\\d{3}")
        } catch {
            XCTFail("ValidatorRegularExpression setup failed")
            return
        }

        validator = ValidatorRegularExpression(regularExpression: regularExpression)
    }

    func testValidateCorrectValues() {
        let result = validator.validate(value: "123")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")
    }

    func testRejectInvalidValues() {
        let result = validator.validate(value: "abc")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Provided value is not in the correct format.")
    }
}
