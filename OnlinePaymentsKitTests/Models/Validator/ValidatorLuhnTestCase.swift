//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import XCTest
@testable import OnlinePaymentsKit

class ValidatorLuhnTestCase: XCTestCase {

    let validator = ValidatorLuhn()
    let request = PaymentRequest(paymentProduct: PaymentProduct(json: [
        "fields": [[:]],
        "id": 1,
        "paymentMethod": "card",
        "displayHints": [
            "displayOrder": 20,
            "label": "Visa",
            "logo": "/this/is_a_test.png"
        ]
    ])!)

    func testValidateCorrect() {
        validator.validate(value: "4242424242424242", for: request)
        XCTAssert(validator.errors.count == 0, "Valid value considered invalid")
    }

    func testValidateIncorrect() {
        validator.validate(value: "1111", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }
}
