//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class ValidatorEmailAddressTestCase: XCTestCase {

    let validator = ValidatorEmailAddress()
    var request: PaymentRequest!

    override func setUp() {
        let paymentProductJSON = Data("""
        {
            "fields": [
                {
                    "id": "email",
                    "type": "string",
                    "displayHints": {
                        "displayOrder": 0,
                        "formElement": {
                            "type": "text"
                        }
                    }
                }
            ],
            "id": 1,
            "paymentMethod": "card",
            "displayHints": {
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            },
            "usesRedirectionTo3rdParty": false
        }
        """.utf8)

        guard let paymentProduct = try? JSONDecoder().decode(PaymentProduct.self, from: paymentProductJSON) else {
            XCTFail("Not a valid PaymentProduct")
            return
        }

        request = PaymentRequest(paymentProduct: paymentProduct)
    }

    func testValidateCorrect1() {
        request.setValue(forField: "email", value: "test@example.com")
        _ = validator.validate(field: "email", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect3() {
        request.setValue(forField: "email", value: "\"Fred Bloggs\"@example.com")
        _ = validator.validate(field: "email", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect4() {
        request.setValue(forField: "email", value: "\"Joe\\Blow\"@example.com")
        _ = validator.validate(field: "email", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect6() {
        request.setValue(forField: "email", value: "customer/department=shipping@example.com")
        _ = validator.validate(field: "email", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect7() {
        request.setValue(forField: "email", value: "$A12345@example.com")
        _ = validator.validate(field: "email", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect8() {
        request.setValue(forField: "email", value: "!def!xyz%abc@example.com")
        _ = validator.validate(field: "email", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect9() {
        request.setValue(forField: "email", value: "_somename@example.com")
        _ = validator.validate(field: "email", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect10() {
        request.setValue(forField: "email", value: "\"b(c)d,e:f;g<h>i[j\\k]l@example.com")
        _ = validator.validate(field: "email", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect11() {
        request.setValue(forField: "email", value: "just\"not\"right@example.com")
        _ = validator.validate(field: "email", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect12() {
        request.setValue(forField: "email", value: "this is\"not\"allowed@example.com")
        _ = validator.validate(field: "email", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateCorrect13() {
        request.setValue(forField: "email", value: "this\\ still\"not\\allowed@example.com")
        _ = validator.validate(field: "email", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid address is considered invalid")
    }

    func testValidateIncorrect1() {
        request.setValue(forField: "email", value: "Abc.example.com")
        _ = validator.validate(field: "email", in: request)

        XCTAssertEqual(validator.errors.count, 1, "Invalid address is considered valid")
        XCTAssertEqual(validator.errors[0].errorMessage, "emailAddress")
        XCTAssertEqual(validator.errors[0].paymentProductFieldId, "email")
        XCTAssertEqual(validator.errors[0].rule?.type, .emailAddress)
    }

    func testValidateIncorrect2() {
        request.setValue(forField: "email", value: "A@b@c@example.com")
        _ = validator.validate(field: "email", in: request)

        XCTAssertEqual(validator.errors.count, 1, "Invalid address is considered valid")
        XCTAssertEqual(validator.errors[0].errorMessage, "emailAddress")
        XCTAssertEqual(validator.errors[0].paymentProductFieldId, "email")
        XCTAssertEqual(validator.errors[0].rule?.type, .emailAddress)
    }

    func testValidateIncorrect3() {
        request.setValue(forField: "email", value: "\"Abc@def\"@example.com")
        _ = validator.validate(field: "email", in: request)

        XCTAssertEqual(validator.errors.count, 1, "Invalid address is considered valid")
        XCTAssertEqual(validator.errors[0].errorMessage, "emailAddress")
        XCTAssertEqual(validator.errors[0].paymentProductFieldId, "email")
        XCTAssertEqual(validator.errors[0].rule?.type, .emailAddress)
    }
}
