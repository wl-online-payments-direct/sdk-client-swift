//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class PaymentProductFieldTestCase: XCTestCase {

    var field: PaymentProductField!
    var request: PaymentRequest!

    override func setUp() {
        super.setUp()

        let fieldJSON = Data("""
        {
            "displayHints": {
                "alwaysShow": false,
                "displayOrder": 10,
                "formElement": {
                    "type": "text"
                },
                "label": "Card number",
                "mask": "{{9999}} {{9999}} {{9999}} {{9999}} {{999}}",
                "obfuscate": false,
                "placeholderLabel": "**** **** **** ****",
                "preferredInputType": "IntegerKeyboard"
            },
            "dataRestrictions": {
               "isRequired": false,
               "validators": {
                  "length": {
                     "minLength": 4,
                     "maxLength": 6
                  },
                  "range": {
                    "minValue": 50,
                    "maxValue": 60
                  }
               }
            },
            "id": "cardNumber",
            "type": "numericstring"
        }
        """.utf8)
        guard let field = try? JSONDecoder().decode(PaymentProductField.self, from: fieldJSON) else {
            XCTFail("Not a valid PaymenProductField")
            return
        }
        self.field = field

        let paymentProductJSON = Data("""
        {
            "fields": [],
            "id": 1,
            "paymentMethod": "card",
            "displayHints": {
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/this/is_a_test.png"
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

    func testValidateValueCorrect() {
        _ = field.validateValue(value: "0055")
        XCTAssertEqual(field.errorMessageIds.count, 0, "Unexpected errors after validation")
    }

    func testValidateValueIncorrect() {
        _ = field.validateValue(value: "0")
        XCTAssertEqual(field.errorMessageIds.count, 2, "Unexpected number of errors after validation")
    }

    func testTypes() {
        _ = field.dataRestrictions.isRequired = true
        _ = field.validateValue(value: "0055")
        XCTAssertEqual(field.errorMessageIds.count, 0, "Unexpected errors after validation")

        _ = field.validateValue(value: "0055")
        XCTAssertEqual(field.errorMessageIds.count, 0, "Unexpected errors after validation")

        field.type = .numericString
        _ = field.validateValue(value: "a")
        XCTAssertEqual(field.errorMessageIds.count, 2, "Unexpected number of errors after validation")
    }

    func testPaymentProductField() {
        XCTAssertEqual(field.identifier, "cardNumber")
        XCTAssertEqual(field.type, FieldType.numericString)
        XCTAssertEqual(field.dataRestrictions.isRequired, false)
        XCTAssertEqual(field.dataRestrictions.validators.validators.count, 2)
    }

    func testDisplayHints() {
        XCTAssertFalse(field.displayHints.alwaysShow, "Expected alwaysShow to be false")
        XCTAssertEqual(field.displayHints.displayOrder, 10)
        XCTAssertEqual(field.displayHints.formElement.type, FormElementType.textType)
        XCTAssertEqual(field.displayHints.label, "Card number")
        XCTAssertEqual(field.displayHints.mask, "{{9999}} {{9999}} {{9999}} {{9999}} {{999}}")
        XCTAssertFalse(field.displayHints.obfuscate, "Expected obfuscate to be false")
        XCTAssertEqual(field.displayHints.placeholderLabel, "**** **** **** ****")
        XCTAssertEqual(field.displayHints.preferredInputType, PreferredInputType.integerKeyboard)
    }
}
