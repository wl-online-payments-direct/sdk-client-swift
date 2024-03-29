//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import XCTest
@testable import OnlinePaymentsKit

class ValidatorLuhnTestCase: XCTestCase {

    let validator = ValidatorLuhn()
    var request: PaymentRequest!

    override func setUp() {
        super.setUp()

        let paymentProductJSON = Data("""
        {
            "fields": [
                {
                    "id": "cardnumber",
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

    func testValidateCorrect() {
        request.setValue(forField: "cardnumber", value: "4242424242424242")
        _ = validator.validate(field: "cardnumber", in: request)
        XCTAssert(validator.errors.count == 0, "Valid value considered invalid")
    }

    func testValidateIncorrect() {
        request.setValue(forField: "cardnumber", value: "1111")
        _ = validator.validate(field: "cardnumber", in: request)

        XCTAssertEqual(validator.errors.count, 1, "Invalid value considered valid")
        XCTAssertEqual(validator.errors[0].errorMessage, "luhn")
        XCTAssertEqual(validator.errors[0].paymentProductFieldId, "cardnumber")
        XCTAssertEqual(validator.errors[0].rule?.validationType, .luhn)
    }
}
