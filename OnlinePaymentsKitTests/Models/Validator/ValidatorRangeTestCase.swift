//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class ValidatorRangeTestCase: XCTestCase {

    let validator = ValidatorRange(minValue: 40, maxValue: 50)
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

    func testValidateCorrect1() {
        validator.validate(value: "40", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")
    }

    func testValidateCorrect2() {
        validator.validate(value: "45", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")
    }

    func testValidateCorrect3() {
        validator.validate(value: "50", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")
    }

    func testValidateIncorrect1() {
        validator.validate(value: "aaa", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }

    func testValidateIncorrect2() {
        validator.validate(value: "39", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }

    func testValidateIncorrect3() {
        validator.validate(value: "51", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }
}
