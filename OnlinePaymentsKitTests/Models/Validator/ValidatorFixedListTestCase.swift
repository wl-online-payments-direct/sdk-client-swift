//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class ValidatorFixedListTestCase: XCTestCase {

    var validator: ValidatorFixedList!
    var request: PaymentRequest!

    override func setUp() {
        super.setUp()
        validator = ValidatorFixedList.init(allowedValues: ["1"])

        let paymentProductJSON = Data("""
        {
            "fields": [
                {
                    "id": "fixedList",
                    "type": "numericstring",
                    "displayHints": {
                        "displayOrder": 0,
                        "formElement": {
                            "type": "list"
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

    func testValidateCorrect() {
        request.setValue(forField: "fixedList", value: "1")
        _ = validator.validate(field: "fixedList", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")

        request.setValue(forField: "fixedList", value: "999")
        _ = validator.validate(field: "fixedList", in: request)

        XCTAssertEqual(validator.errors.count, 1, "Invalid value considered valid")
        XCTAssertEqual(validator.errors[0].errorMessage, "fixedList")
        XCTAssertEqual(validator.errors[0].paymentProductFieldId, "fixedList")
        XCTAssertEqual(validator.errors[0].rule?.validationType, .fixedList)
    }

    func testValidateIncorrect() {
        request.setValue(forField: "fixedList", value: "X")
        _ = validator.validate(field: "fixedList", in: request)

        XCTAssertEqual(validator.errors.count, 1, "Invalid value considered valid")
        XCTAssertEqual(validator.errors[0].errorMessage, "fixedList")
        XCTAssertEqual(validator.errors[0].paymentProductFieldId, "fixedList")
        XCTAssertEqual(validator.errors[0].rule?.validationType, .fixedList)
    }

}
