//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class ValidatorFixedListTestCase: XCTestCase {

    var validator: ValidatorFixedList!
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

    override func setUp() {
        super.setUp()
        validator = ValidatorFixedList.init(allowedValues: ["1"])
    }

    func testValidateCorrect() {
        validator.validate(value: "1", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")

        validator.validate(value: "999", for: request)
        XCTAssertEqual(validator.errors.count, 1, "Invalid value considered valid")
    }

    func testValidateIncorrect() {
        validator.validate(value: "X", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }

}
