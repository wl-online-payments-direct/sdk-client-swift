//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
import OHHTTPStubs

@testable import OnlinePaymentsKit

class SessionTestCase: XCTestCase {
    let host = "example.com"
    
    var session = Session(clientSessionId: "client-session-id", customerId: "customer-id",baseURL: "https://example.com/client/v1", assetBaseURL: "https://example.com/client/v1", appIdentifier: "")
    let context = PaymentContext(amountOfMoney: PaymentAmountOfMoney(totalAmount: 3, currencyCode: .EUR), isRecurring: true, countryCode: .NL)
    
    override func setUp() {
        super.setUp()
        
        session.assetManager.fileManager = StubFileManager()
        session.assetManager.sdkBundle = StubBundle()
    }
    
    func testPaymentProductsForContext(){
        stub(condition: isHost(host) && isPath("/client/v1/customer-id/products") && isMethodGET()) { _ in
            let response = [
                "paymentProducts": [
                    [
                        "allowsRecurring": true,
                        "allowsTokenization": true,
                        "displayHints": [
                            "displayOrder": 20,
                            "label": "Visa",
                            "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                        ],
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
                            "logo": "/templates/master/global/css/img/ppimages/pp_logo_2_v1.png"
                        ],
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
                            "logo": "/templates/master/global/css/img/ppimages/pp_logo_3_v1.png"
                        ],
                        "id": 3,
                        "maxAmount": 1000000,
                        "mobileIntegrationLevel": "OPTIMISED_SUPPORT",
                        "paymentMethod": "card",
                        "paymentProductGroup": "cards"
                    ]
                ]
            ]
            return OHHTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        let expectation = self.expectation(description: "Response provided")
        session.paymentProducts(for: context, success: { paymentProducts in
            print("Success")
            expectation.fulfill()
        }) { (error) in
            XCTFail("Unexpected failure while testing paymentProductWithId: \(error.localizedDescription)")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testPaymentProductNetworksForProductId(){
        // TODO: Test needs to be made
    }
    
    func testPaymentProductWithId(){
        // TODO: Merges two response stubs, need to find a way to make stubs specific for a url. (Does not work with get variables)
        stub(condition: isHost(host)) { _ in
            let response = [
                "paymentProductGroups": [
                    [
                        "displayHints": [
                            "displayOrder": 20,
                            "label": "Cards",
                            "logo": "/templates/master/global/css/img/ppimages/group-card.png"
                        ],
                        "id": "cards"
                    ]
                ],
                "allowsRecurring": true,
                "allowsTokenization": true,
                "displayHints": [
                    "displayOrder": 20,
                    "label": "Visa",
                    "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                ],
                "fields": [
                    [
                        "dataRestrictions": [
                            "isRequired": true,
                            "validators": [
                                "length": [
                                    "maxLength": 19,
                                    "minLength": 12
                                ],
                                "luhn": [
                                    
                                ],"expirationDate": [
                                    
                                ],
                                  "regularExpression": [
                                    "regularExpression": "(?:0[1-9]|1[0-2])[0-9]{2}"
                                ]
                            ]
                        ],
                        "displayHints": [
                            "displayOrder": 10,
                            "formElement": [
                                "type": "currency"
                            ],
                            "label": "Card number:",
                            "mask": "{{9999}} {{9999}} {{9999}} {{9999}} {{999}}",
                            "obfuscate": false,
                            "placeholderLabel": "**** **** **** ****",
                            "preferredInputType": "IntegerKeyboard"
                        ],
                        "id": "cardNumber",
                        "type": "numericstring"
                    ]
                ],
                "id": 1,
                "maxAmount": 1000000,
                "mobileIntegrationLevel": "OPTIMISED_SUPPORT",
                "paymentMethod": "card",
                "paymentProductGroup": "cards"
                ] as [String : Any]
            return OHHTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        let expectation = self.expectation(description: "Response provided")
        
        session.paymentProduct(withId: "1", context: context, success: { product in
            self.check(paymentProduct: product)
            
            // Check if paymentProductMapping cache is properly filled
            let key = "1-3-EUR-NL-YES"
            guard let cachedProduct = self.session.paymentProductMapping[key] as? PaymentProduct else {
                XCTFail("DirectoryEntriesMapping not properly populated")
                return
            }
            self.check(paymentProduct: cachedProduct)
            
            // Check initializeImages
            XCTAssertEqual(product.displayHints.logoImage?.accessibilityLabel, "logoStubResponse")
            for i in 0..<product.fields.paymentProductFields.count {
                let field = product.fields.paymentProductFields[i]
                
                // TODO: This is never true. Should analyse why imagePath is never set in JSON conversion. And make test that tests the behavior when it is set.
                if field.displayHints.tooltip?.imagePath != nil {
                    XCTAssertEqual(field.displayHints.tooltip?.image?.accessibilityLabel, "tooltipStubResponse-field\(i)")
                }
            }
            expectation.fulfill()
        }) { (error) in
            XCTFail("Unexpected failure while testing paymentProductWithId: \(error.localizedDescription)")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
    
    fileprivate func check(paymentProduct product: PaymentProduct){
        XCTAssertEqual(product.identifier, "1", "Received product id not as expected")
        XCTAssertEqual(product.displayHints.displayOrder, 20, "Received product displayOrder not as expected")
        XCTAssertEqual(product.displayHints.logoPath, "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png", "Received product logoPath not as expected")
        
        guard let field = product.fields.paymentProductFields.first else {
            XCTFail("Received product field not as expected")
            return
        }
        
        // Data Restrictions
        XCTAssertEqual(field.dataRestrictions.isRequired, true, "Received product field isRequired not as expected")
        guard let lengthValidator = field.dataRestrictions.validators.validators[2] as? ValidatorLength else {
            XCTFail("Received product field length validator not as expected")
            return
        }
        XCTAssertEqual(lengthValidator.maxLength, 19, "Received product field length validator maxlength not as expected")
        XCTAssertEqual(lengthValidator.minLength, 12, "Received product field length validator minLength not as expected")
        XCTAssertEqual(field.dataRestrictions.validators.validators.count, 4, "Received product fields count not as expected")
        
        // Display Hints
        XCTAssertEqual(field.displayHints.displayOrder, 10, "Received product field displayHints displayOrder not as expected")
        XCTAssertEqual(field.displayHints.mask, "{{9999}} {{9999}} {{9999}} {{9999}} {{999}}", "Received product field displayHints mask not as expected")
        XCTAssertEqual(field.displayHints.obfuscate, false, "Received product field displayHints obfuscate not as expected")
        XCTAssertEqual(field.displayHints.preferredInputType, PreferredInputType.integerKeyboard, "Received product field displayHints preferredInputType not as expected")
        XCTAssertEqual(field.displayHints.formElement.type, FormElementType.currencyType, "Received product field displayHints formElement type not as expected")
    }
    
    func testPaymentProductNetworks(){
        let productID = "1"
        stub(condition: isHost("\(host)") && isPath("/client/v1/customer-id/products/\(productID)/networks") && isMethodGET()) { _ in
            let response = [
                "networks" : [ "amex", "discover", "masterCard", "visa" ]
            ]
            return OHHTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        let expectation = self.expectation(description: "Response provided")
        session.paymentProductNetworks(forProductId: productID, context: context, success: { (networks) in
            XCTAssertTrue(networks.paymentProductNetworks.count == 4, "Expected four networks.")
            
            expectation.fulfill()
        }) { (error) in
            XCTFail("Retrieving networks failed; Exception: \(error).")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
    
    func testPaymentProductFailNetworks(){
        let productID = "1"
        stub(condition: isHost("\(host)") && isPath("/client/v1/customer-id/products/\(productID)/networks") && isMethodGET()) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        let expectation = self.expectation(description: "Response provided")
        session.paymentProductNetworks(forProductId: productID, context: context, success: { (networks) in
            XCTFail("Should have jumped to the error block.")
            
            expectation.fulfill()
        }) { (error) in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testIinDetailsForPartialCreditCardNumber(){
        _ = PaymentAmountOfMoney(totalAmount: 0, currencyCode: .EUR)
        
        stub(condition: isHost(host)) { _ in
            let response = [
                "countryCode": "RU",
                "paymentProductId": 3,
                "isAllowedInContext": true
                ] as [String : Any]
            return OHHTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        // Test too short partial credit card number
        var expectation = self.expectation(description: "Response provided")
        session.iinDetails(forPartialCreditCardNumber: "01234", context: context, success: { iinDetailsResponse in
            XCTAssertEqual(iinDetailsResponse.status.hashValue, IINStatus.notEnoughDigits.hashValue)
            expectation.fulfill()
        }, failure: { error in
            XCTFail("Bad response")
        })
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
        
        // Test a successful response
        expectation = self.expectation(description: "Response provided")
        session.iinDetails(forPartialCreditCardNumber: "012345", context: context, success: { iinDetailsResponse in
            XCTAssertEqual(iinDetailsResponse.status.hashValue, IINStatus.supported.hashValue)
            XCTAssertEqual(iinDetailsResponse.countryCode, .RU)
            XCTAssertEqual(iinDetailsResponse.paymentProductId, "3")
            expectation.fulfill()
        }, failure: { error in
            XCTFail("Bad response")
        })
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
        
        // Test a pending request
        expectation = self.expectation(description: "Response provided")
        session.iinLookupPending = true
        session.iinDetails(forPartialCreditCardNumber: "012345", context: context, success: { iinDetailsResponse in
            XCTAssertEqual(iinDetailsResponse.status.hashValue, IINStatus.pending.hashValue)
            expectation.fulfill()
        }, failure: { error in
            XCTFail("Bad response")
        })
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
 
    func testClientSessionId(){
        XCTAssertEqual(session.clientSessionId, "client-session-id")
    }
}
