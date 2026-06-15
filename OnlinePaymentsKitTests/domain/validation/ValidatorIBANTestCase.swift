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

final class ValidatorIBANTestCase: XCTestCase {

    private let validator = ValidatorIBAN()

    // MARK: - CSV Tests

    func testValidateReturnsTrueForValidIban() {
        let result = validator.validate(value: "GB29NWBK60161331926819")

        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")
    }

    func testValidateReturnsTrueForIbanWithSpaces() {
        let result = validator.validate(value: "GB29 NWBK 6016 1331 9268 19")

        XCTAssertTrue(result.valid)
    }

    func testValidateReturnsFalseForInvalidIbanChecksum() {
        // Same structure as valid IBAN but check digits changed to 00
        let result = validator.validate(value: "GB00NWBK60161331926819")

        XCTAssertFalse(result.valid)
    }

    func testValidateReturnsFalseForNonIbanValues() {
        XCTAssertFalse(validator.validate(value: "not-an-iban").valid)
        XCTAssertFalse(validator.validate(value: "1234567890").valid)
        XCTAssertFalse(validator.validate(value: "").valid)
    }
}
