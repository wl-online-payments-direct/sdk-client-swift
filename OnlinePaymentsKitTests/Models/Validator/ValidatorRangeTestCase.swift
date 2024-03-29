//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class ValidatorRangeTestCase: XCTestCase {

    let validator = ValidatorRange(minValue: 40, maxValue: 50)
    var request: PaymentRequest!

    override func setUp() {
        super.setUp()

        let paymentProductJSON = Data("""
        {
            "fields": [
                {
                    "id": "ccv",
                    "type": "numericstring",
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
        request.setValue(forField: "ccv", value: "40")
        _ = validator.validate(field: "ccv", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")
    }

    func testValidateCorrect2() {
        request.setValue(forField: "ccv", value: "45")
        _ = validator.validate(field: "ccv", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")
    }

    func testValidateCorrect3() {
        request.setValue(forField: "ccv", value: "50")
        _ = validator.validate(field: "ccv", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")
    }

    func testValidateIncorrect1() {
        request.setValue(forField: "ccv", value: "aaa")
        _ = validator.validate(field: "ccv", in: request)

        XCTAssertEqual(validator.errors.count, 1, "Invalid value considered valid")
        XCTAssertEqual(validator.errors[0].errorMessage, "range")
        XCTAssertEqual(validator.errors[0].paymentProductFieldId, "ccv")
        XCTAssertEqual(validator.errors[0].rule?.validationType, .range)
    }

    func testValidateIncorrect2() {
        request.setValue(forField: "ccv", value: "39")
        _ = validator.validate(field: "ccv", in: request)

        XCTAssertEqual(validator.errors.count, 1, "Invalid value considered valid")
        XCTAssertEqual(validator.errors[0].errorMessage, "range")
        XCTAssertEqual(validator.errors[0].paymentProductFieldId, "ccv")
        XCTAssertEqual(validator.errors[0].rule?.validationType, .range)
    }

    func testValidateIncorrect3() {
        request.setValue(forField: "ccv", value: "51")
        _ = validator.validate(field: "ccv", in: request)

        XCTAssertEqual(validator.errors.count, 1, "Invalid value considered valid")
        XCTAssertEqual(validator.errors[0].errorMessage, "range")
        XCTAssertEqual(validator.errors[0].paymentProductFieldId, "ccv")
        XCTAssertEqual(validator.errors[0].rule?.validationType, .range)
    }
}
