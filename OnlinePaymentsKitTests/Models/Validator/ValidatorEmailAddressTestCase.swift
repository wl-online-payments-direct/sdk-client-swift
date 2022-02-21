//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class ValidatorEmailAddressTestCase: XCTestCase {

    let validator = ValidatorEmailAddress()
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
        validator.validate(value: "test@example.com", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect3() {
        validator.validate(value: "\"Fred Bloggs\"@example.com", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect4() {
        validator.validate(value: "\"Joe\\Blow\"@example.com", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect6() {
        validator.validate(value: "customer/department=shipping@example.com", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect7() {
        validator.validate(value: "$A12345@example.com", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect8() {
        validator.validate(value: "!def!xyz%abc@example.com", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect9() {
        validator.validate(value: "_somename@example.com", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect10() {
        validator.validate(value: "\"b(c)d,e:f;g<h>i[j\\k]l@example.com", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect11() {
        validator.validate(value: "just\"not\"right@example.com", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect12() {
        validator.validate(value: "this is\"not\"allowed@example.com", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect13() {
        validator.validate(value: "this\\ still\"not\\allowed@example.com", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateIncorrect1() {
        validator.validate(value: "Abc.example.com", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid address is considered valid")
    }

    func testValidateIncorrect2() {
        validator.validate(value: "A@b@c@example.com", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid address is considered valid")
    }

    func testValidateIncorrect7() {
        validator.validate(value: "\"Abc@def\"@example.com", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid address is considered valid")
    }
}
