//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class PaymentProductTestCase: XCTestCase {

    let paymentProduct = PaymentProduct(json: [
        "fields": [[:]],
        "id": 1,
        "paymentMethod": "card",
        "displayHints": [
            "displayOrder": 20,
            "label": "Visa",
            "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
        ]
    ])!
    let field = PaymentProductField(json: [
        "displayHints": [
            "formElement": [
                "type": "text"
            ]
        ],
        "id": "cardNumber",
        "type": "numericstring"
    ])!

    override func setUp() {
        super.setUp()

        paymentProduct.fields.paymentProductFields.append(field)
    }

    func testPaymentProductFieldWithIdExists() {
        let paymentField = paymentProduct.paymentProductField(withId: "cardNumber")
        XCTAssert(field === paymentField, "Retrieved field is unequal to added field")
    }

    func testPaymentProductFieldWithIdNil() {
        let paymentField = paymentProduct.paymentProductField(withId: "X")
        XCTAssertNil(paymentField, "Retrieved a field while no field should be returned")
    }

}
