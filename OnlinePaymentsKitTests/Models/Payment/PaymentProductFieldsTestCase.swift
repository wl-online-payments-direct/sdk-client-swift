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

        let field1JSON = Data("""
        {
            "displayHints": {
                "displayOrder": 1,
                "formElement": {
                    "type": "text"
                }
            },
            "id": "field1",
            "type": "numericstring"
        }
        """.utf8)

        let field2JSON = Data("""
        {
            "displayHints": {
                "displayOrder": 100,
                "formElement": {
                    "type": "text"
                }
            },
            "id": "field2",
            "type": "numericstring"
        }
        """.utf8)

        let field3JSON = Data("""
        {
            "displayHints": {
                "displayOrder": 4,
                "formElement": {
                    "type": "text"
                }
            },
            "id": "field3",
            "type": "numericstring"
        }
        """.utf8)

        let field4JSON = Data("""
        {
            "displayHints": {
                "displayOrder": 50,
                "formElement": {
                    "type": "text"
                }
            },
            "id": "field4",
            "type": "numericstring"
        }
        """.utf8)

        let field5JSON = Data("""
        {
            "displayHints": {
                "displayOrder": 3,
                "formElement": {
                    "type": "text"
                }
            },
            "id": "field5",
            "type": "numericstring"
        }
        """.utf8)

        guard let field1 = try? JSONDecoder().decode(PaymentProductField.self, from: field1JSON),
              let field2 = try? JSONDecoder().decode(PaymentProductField.self, from: field2JSON),
              let field3 = try? JSONDecoder().decode(PaymentProductField.self, from: field3JSON),
              let field4 = try? JSONDecoder().decode(PaymentProductField.self, from: field4JSON),
              let field5 = try? JSONDecoder().decode(PaymentProductField.self, from: field5JSON) else {
            XCTFail("Not all fields are a valid PaymentProductField object")
            return
        }

        fields.paymentProductFields.append(field1)
        fields.paymentProductFields.append(field2)
        fields.paymentProductFields.append(field3)
        fields.paymentProductFields.append(field4)
        fields.paymentProductFields.append(field5)
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
