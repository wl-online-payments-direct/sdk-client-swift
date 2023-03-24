//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 07/03/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class BasicPaymentProductsTestCase: XCTestCase {

    let products = BasicPaymentProducts(json: [
        "paymentProducts": [
            [
                "fields": [[:]],
                "id": 1,
                "paymentMethod": "card",
                "displayHints": [
                    "displayOrder": 20,
                    "label": "Visa",
                    "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                ]
            ],
            [
                "fields": [[:]],
                "id": 2,
                "paymentMethod": "card",
                "displayHints": [
                    "displayOrder": 21,
                    "label": "MasterCard",
                    "logo": "/templates/master/global/css/img/ppimages/pp_logo_2_v1.png"
                ]
            ]
        ],
        "hasAccountsOnFile": false
    ])

    func testBasicPaymentProducts() {
        XCTAssertEqual(products.paymentProducts.count, 2, "Unexpected amount of products retrieved")
        XCTAssertFalse(products.hasAccountsOnFile)
    }

    func testSameBasicPaymentProducts() {
        let sameProducts = BasicPaymentProducts(json: [
            "paymentProducts": [
                [
                    "fields": [[:]],
                    "id": 1,
                    "paymentMethod": "card",
                    "displayHints": [
                        "displayOrder": 20,
                        "label": "Visa",
                        "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                    ]
                ],
                [
                    "fields": [[:]],
                    "id": 2,
                    "paymentMethod": "card",
                    "displayHints": [
                        "displayOrder": 21,
                        "label": "MasterCard",
                        "logo": "/templates/master/global/css/img/ppimages/pp_logo_2_v1.png"
                    ]
                ]
            ],
            "hasAccountsOnFile": false
        ])

        XCTAssertTrue(products == sameProducts)
        XCTAssertTrue(products.isEqual(sameProducts))
    }

    func testOtherBasicPaymentProducts() {
        let otherProducts = BasicPaymentProducts(json: [
            "paymentProducts": [
                [
                    "fields": [[:]],
                    "id": 1,
                    "paymentMethod": "card",
                    "displayHints": [
                        "displayOrder": 20,
                        "label": "Visa",
                        "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                    ]
                ],
                [
                    "fields": [[:]],
                    "id": 3,
                    "paymentMethod": "card",
                    "displayHints": [
                        "displayOrder": 22,
                        "label": "Maestro",
                        "logo": "/templates/master/global/css/img/ppimages/pp_logo_3_v1.png"
                    ]
                ]
            ],
            "hasAccountsOnFile": false
        ])

        XCTAssertFalse(products == otherProducts)
        XCTAssertFalse(products.isEqual(otherProducts))
    }
}
