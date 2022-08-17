//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class PaymentProductFieldsTestCase: XCTestCase {

    let fields = PaymentProductFields()

    override func setUp() {
        super.setUp()

        let field1 = PaymentProductField(json: [
            "displayHints": [
                "displayOrder": 1,
                "formElement": [
                    "type": "text"
                ]
            ],
            "id": "field1",
            "type": "numericstring"
        ])!
        let field2 = PaymentProductField(json: [
            "displayHints": [
                "displayOrder": 100,
                "formElement": [
                    "type": "text"
                ]
            ],
            "id": "field2",
            "type": "numericstring"
        ])!
        let field3 = PaymentProductField(json: [
            "displayHints": [
                "displayOrder": 4,
                "formElement": [
                    "type": "text"
                ]
            ],
            "id": "field3",
            "type": "numericstring"
        ])!
        let field4 = PaymentProductField(json: [
            "displayHints": [
                "displayOrder": 50,
                "formElement": [
                    "type": "text"
                ]
            ],
            "id": "field4",
            "type": "numericstring"
        ])!
        let field5 = PaymentProductField(json: [
            "displayHints": [
                "displayOrder": 3,
                "formElement": [
                    "type": "text"
                ]
            ],
            "id": "field5",
            "type": "numericstring"
        ])!

        fields.paymentProductFields.append(field1)
        fields.paymentProductFields.append(field2)
        fields.paymentProductFields.append(field3)
        fields.paymentProductFields.append(field4)
        fields.paymentProductFields.append(field5)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSort() {
        fields.sort()

        var displayOrder = -1
        for field in fields.paymentProductFields {
            let fieldOrder = field.displayHints.displayOrder
            if displayOrder > fieldOrder {
                XCTFail("Fields not sorted according to display order")
            }
            displayOrder = field.displayHints.displayOrder
        }
    }

}
