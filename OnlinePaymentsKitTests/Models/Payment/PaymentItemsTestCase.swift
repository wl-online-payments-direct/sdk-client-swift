//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
import OHHTTPStubs
import OHHTTPStubsSwift

@testable import OnlinePaymentsKit

class PaymentItemsTestCase: XCTestCase {

    let host = "example.com"

    var session = StubSession(clientSessionId: "client-session-id",
                              customerId: "customer-id",
                              baseURL: "https://example.com",
                              assetBaseURL: "https://example.com",
                              appIdentifier: "",
                              loggingEnabled: false,
                              sdkIdentifier: SDKConstants.kSDKIdentifier
                        )
    let context = PaymentContext(amountOfMoney: AmountOfMoney(totalAmount: 3, currencyCode: "EUR"),
                                 isRecurring: true,
                                 countryCode: "NL")

    func testPaymentItems() {
        stub(condition: isHost("example.com")) { _ in
            let response = [
                "paymentProducts": [
                    [
                        "allowsRecurring": true,
                        "allowsTokenization": true,
                        "displayHints": [
                            "displayOrder": 20,
                            "label": "Visa",
                            "logo": "https://example.com/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                        ],
                        "displayHintsList": [[
                            "displayOrder": 20,
                            "label": "Visa",
                            "logo": "https://example.com/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                        ]],
                        "usesRedirectionTo3rdParty": false,
                        "id": 1,
                        "maxAmount": 1000000,
                        "mobileIntegrationLevel": "OPTIMISED_SUPPORT",
                        "paymentMethod": "card",
                        "paymentProductGroup": "cards"
                    ],
                    [
                        "allowsRecurring": true,
                        "allowsTokenization": true,
                        "displayHints": [
                            "displayOrder": 19,
                            "label": "American Express",
                            "logo": "https://example.com/templates/master/global/css/img/ppimages/pp_logo_2_v1.png"
                        ],
                        "displayHintsList": [[
                            "displayOrder": 19,
                            "label": "American Express",
                            "logo": "https://example.com/templates/master/global/css/img/ppimages/pp_logo_2_v1.png"
                        ]],
                        "usesRedirectionTo3rdParty": false,
                        "id": 2,
                        "maxAmount": 1000000,
                        "mobileIntegrationLevel": "OPTIMISED_SUPPORT",
                        "paymentMethod": "card",
                        "paymentProductGroup": "cards"
                    ],
                    [
                        "allowsRecurring": true,
                        "allowsTokenization": true,
                        "displayHints": [
                            "displayOrder": 18,
                            "label": "MasterCard",
                            "logo": "https://example.com/templates/master/global/css/img/ppimages/pp_logo_3_v1.png"
                        ],
                        "displayHintsList": [[
                            "displayOrder": 18,
                            "label": "MasterCard",
                            "logo": "https://example.com/templates/master/global/css/img/ppimages/pp_logo_3_v1.png"
                        ]],
                        "usesRedirectionTo3rdParty": false,
                        "id": 3,
                        "maxAmount": 1000000,
                        "mobileIntegrationLevel": "OPTIMISED_SUPPORT",
                        "paymentMethod": "card",
                        "paymentProductGroup": "cards",
                        "accountsOnFile": [
                            [
                                "id": 1,
                                "paymentProductId": 3,
                                "displayHints": [
                                    [
                                        "attributeKey": "17",
                                        "mask": "12345"
                                    ],
                                    [
                                        "attributeKey": "2",
                                        "mask": "{{99999}}"
                                    ]
                                ],
                                "attributes": [
                                    [
                                        "key": "1",
                                        "value": "2",
                                        "mustWriteReason": "Must",
                                        "status": "READ_ONLY"
                                    ]
                                ]
                            ],
                            [
                                "id": 2,
                                "paymentProductId": 4
                            ]
                        ]
                    ]
                ]
            ]
            return
                HTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        stub(condition: isHost("\(host)") && isPath("/client/v1/customer-id/productgroups") && isMethodGET()) { _ in
            let response = [
                "paymentProductGroups": [
                    [
                        "displayHints": [
                            "displayOrder": 20,
                            "label": "Cards",
                            "logo": "https://example.com/templates/master/global/css/img/ppimages/group-card.png"
                        ],
                        "id": "cards",
                        "accountsOnFile": [
                            [
                                "id": 1,
                                "paymentProductId": 3
                            ],
                            [
                                "id": 2,
                                "paymentProductId": 4
                            ]
                        ]
                    ]
                ]
            ]
            return
                HTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        let expectation = self.expectation(description: "Response provided")
        session.paymentItems(
            for: context,
            success: { (items) in
                items.sort()

                XCTAssertTrue(items.hasAccountsOnFile, "Accounts on file are missing.")

                self.allPaymentItems(basicItems: items.allPaymentItems)

                XCTAssertTrue(items.paymentItem(withIdentifier: "3") != nil, "Payment item was not found.")
                XCTAssertTrue(
                    items.paymentItem(withIdentifier: "999") == nil,
                    "Payment item should not have been found."
                )

                XCTAssertTrue(items.logoPath(forItem: "3") != nil, "Logo path not found.")
                XCTAssertTrue(
                    items.logoPath(forItem: "0000") == nil,
                    "Logo path should been nil: \(String(describing: items.logoPath(forItem: "0000")))."
                )

                let sortedItems = items.paymentItems.sorted {
                    guard let displayOrder0 = $0.displayHints.first?.displayOrder,
                          let displayOrder1 = $1.displayHints.first?.displayOrder else {
                        return false
                    }
                    return displayOrder0 < displayOrder1
                }

                items.sort()
                for index in 0..<sortedItems.count
                    where sortedItems[index].identifier != items.paymentItems[index].identifier {
                        XCTFail(
                            """
                            Sorted order is not the same: \(items.paymentItems[index].identifier),
                            should have been: \(sortedItems[index].identifier)
                            """
                        )
                }

                expectation.fulfill()
            },
            failure: { (error) in
                XCTFail("Unexpected failure while loading Payment groups: \(error.localizedDescription)")
                expectation.fulfill()
            }
        )
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }

        let accountOnFileEmptyJSON = Data("""
        {
            "": ""
        }
        """.utf8)
        let accountOnFileEmpty = try? JSONDecoder().decode(AccountOnFile.self, from: accountOnFileEmptyJSON)
        XCTAssertTrue(accountOnFileEmpty == nil, "Init of the account on file should have failed.")

        let accountOnFileIdStringIdJSON = Data("""
        {
            "id": "string id"
        }
        """.utf8)
        let accountOnFileIdStringId = try? JSONDecoder().decode(AccountOnFile.self, from: accountOnFileIdStringIdJSON)
        XCTAssertTrue(accountOnFileIdStringId == nil, "Init of the account on file should have failed.")
    }

    func allPaymentItems(basicItems: [BasicPaymentItem]) {
        var index = 1
        for item in basicItems {
            for file in item.accountsOnFile.accountsOnFile {
                if let labelTemp = file.displayHints.labelTemplate.labelTemplateItems.first {
                    XCTAssertTrue(labelTemp.attributeKey == "17", "Attribute key incorrect.")
                    XCTAssertTrue(labelTemp.mask == "12345", "Mask incorrect.")
                    XCTAssertTrue(!file.label.isEmpty, "Label should not have been empty.")

                    XCTAssertTrue(file.attributes.attributes.count > 0, "No attributes found.")

                } else {
                    XCTAssertTrue(file.label.isEmpty, "Label should have been empty.")
                }
            }
            if let product = item as? BasicPaymentProduct {
                XCTAssertTrue(product.identifier == "\(index)", "Identifier was incorrect.")
                XCTAssertTrue(
                    product.displayHints.first?.displayOrder != nil,
                    "Display order was nil (\(String(describing: product.displayHints.first?.displayOrder)))."
                )
                XCTAssertTrue(product.allowsTokenization, "Tokenization was false.")
                XCTAssertTrue(product.allowsRecurring, "Recurring was false.")
                XCTAssertTrue(product.paymentMethod == "card", "Payment method was not card.")
            }
            index += 1
        }
    }
}
