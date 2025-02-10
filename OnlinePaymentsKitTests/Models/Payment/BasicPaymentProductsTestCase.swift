//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 07/03/2023
// Copyright © 2025 Global Collect Services. All rights reserved.
//

import XCTest
@testable import OnlinePaymentsKit

class BasicPaymentProductsTestCase: XCTestCase {
    var products: BasicPaymentProducts!
    
    let jsonObject = Data("""
        {
            "paymentProducts": [
                {
                    "fields": [],
                    "id": 1,
                    "paymentMethod": "card",
                    "displayHints": {
                        "displayOrder": 20,
                        "label": "Visa",
                        "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                    },
                    "displayHintsList": [
                        {
                            "displayOrder": 20,
                            "label": "Visa",
                            "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                        }
                    ],
                    "usesRedirectionTo3rdParty": false
                },
                {
                    "fields": [],
                    "id": 2,
                    "paymentMethod": "card",
                    "displayHints": {
                        "displayOrder": 20,
                        "label": "Visa",
                        "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                    },
                    "displayHintsList": [
                        {
                            "displayOrder": 20,
                            "label": "Visa",
                            "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                        }
                    ],
                    "usesRedirectionTo3rdParty": false
                }
            ]
        }
        """.utf8)
    
    override func setUp() {
        super.setUp()

        guard let products = try? JSONDecoder().decode(BasicPaymentProducts.self, from: jsonObject) else {
            XCTFail("Could not deserialize correct BasicPaymentProducts JSON")
            return
        }
        
        self.products = products
    }

    func testBasicPaymentProducts() {
        XCTAssertEqual(products.paymentProducts.count, 2, "Unexpected amount of products retrieved")
        XCTAssertFalse(products.hasAccountsOnFile)
    }

    func testSameBasicPaymentProducts() {
        guard let sameProducts = try? JSONDecoder().decode(BasicPaymentProducts.self, from: jsonObject) else {
            XCTFail("Could not deserialize correct BasicPaymentProducts JSON")
            return
        }

        XCTAssertTrue(products == sameProducts)
        XCTAssertTrue(products.isEqual(sameProducts))
    }

    func testOtherBasicPaymentProducts() {
        let otherJsonObject = Data("""
            {
                "paymentProducts": [
                    {
                        "fields": [],
                        "id": 1,
                        "paymentMethod": "card",
                        "displayHintsList": [
                            {
                                "displayOrder": 20,
                                "label": "Visa",
                                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                            }
                        ],
                        "usesRedirectionTo3rdParty": false
                    },
                    {
                        "fields": [],
                        "id": 3,
                        "paymentMethod": "card",
                        "displayHintsList": [
                            {
                                "displayOrder": 22,
                                "label": "Maestro",
                                "logo": "/templates/master/global/css/img/ppimages/pp_logo_3_v1.png"
                            }
                        ],
                        "usesRedirectionTo3rdParty": false
                    }
                ]
            }
            """.utf8)
        let otherProducts = try? JSONDecoder().decode(BasicPaymentProducts.self, from: otherJsonObject)

        XCTAssertFalse(products == otherProducts)
        XCTAssertFalse(products.isEqual(otherProducts))
    }
}
