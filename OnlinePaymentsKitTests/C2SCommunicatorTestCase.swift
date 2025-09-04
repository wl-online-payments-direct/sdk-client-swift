//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import OHHTTPStubs
import OHHTTPStubsSwift
import PassKit
import XCTest

@testable import OnlinePaymentsKit

class C2SCommunicatorTestCase: XCTestCase {

    var communicator: C2SCommunicator!
    var configuration: C2SCommunicatorConfiguration!
    let context =
        PaymentContext(
            amountOfMoney: AmountOfMoney(totalAmount: 3, currencyCode: "EUR"),
            isRecurring: true,
            countryCode: "NL"
        )

    var applePaymentProduct: BasicPaymentProduct?

    override func setUp() {
        super.setUp()

        let applePaymentProductJSON = Data(
            """
            {
                "allowsRecurring": false,
                "allowsTokenization": false,
                "displayHints": {
                    "displayOrder": 2,
                    "label": "APPLEPAY",
                    "logo": "https://assets.test.cdn.v-psp.com/hpp/44df01245ad87dda3dcf/images/pm/APPLEPAY.gif"
                },
                "displayHintsList": [
                    {
                        "displayOrder": 2,
                        "label": "APPLEPAY",
                        "logo": "https://assets.test.cdn.v-psp.com/hpp/44df01245ad87dda3dcf/images/pm/APPLEPAY.gif"
                    }
                ],
                "fields": [],
                "id": \(Int(SDKConstants.kApplePayIdentifier)!),
                "paymentMethod": "mobile",
                "usesRedirectionTo3rdParty": false,
                "paymentProduct302SpecificData": { "networks": ["Visa", "MasterCard"] },
                "allowsAuthentication": false
            }
            """.utf8
        )

        applePaymentProduct = try? JSONDecoder().decode(BasicPaymentProduct.self, from: applePaymentProductJSON)

        configuration =
            C2SCommunicatorConfiguration(
                clientSessionId: "1",
                customerId: "1",
                baseURL: "https://example.com/client/v1",
                assetBaseURL: "https://example.com/client/v1",
                appIdentifier: ""
            )
        communicator = C2SCommunicator(configuration: configuration)
    }

    func testApplePayAvailabilityWithoutApplePay() {
        let paymentProducts = BasicPaymentProducts()

        let expectation = self.expectation(description: "Response provided")

        communicator.checkApplePayAvailability(
            with: paymentProducts,
            for: context,
            success: { _ in
                expectation.fulfill()
            },
            failure: { (error) in
                XCTFail("Unexpected failure while testing checkApplePayAvailability: \(error.localizedDescription)")
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testApplePayAvailabilityWithApplePay() {
        stub(condition: isHost("example.com")) { _ in
            let response = [
                "networks": ["amex", "discover", "masterCard", "visa"]
            ]
            return
                HTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        let paymentProducts = BasicPaymentProducts()

        guard let applePaymentProduct else {
            XCTFail("Not a valid BasicPaymentProduct")
            return
        }
        paymentProducts.paymentProducts.append(applePaymentProduct)

        let expectation = self.expectation(description: "Response provided")

        communicator.checkApplePayAvailability(
            with: paymentProducts,
            for: context,
            success: { (products) in
                XCTAssertEqual(products.paymentProducts.count, 1)
                expectation.fulfill()
            },
            failure: { (error) in
                XCTFail("Unexpected failure while testing checkApplePayAvailability: \(error.localizedDescription)")
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testPaymentProductForContext() {
        stub(condition: isHost("example.com")) { _ in
            let response = [
                "paymentProducts": [
                    [
                        "allowsRecurring": true,
                        "allowsTokenization": true,
                        "displayHints": [
                            "displayOrder": 20,
                            "label": "Visa",
                            "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png",
                        ],
                        "usesRedirectionTo3rdParty": false,
                        "id": 1,
                        "maxAmount": 1_000_000,
                        "mobileIntegrationLevel": "OPTIMISED_SUPPORT",
                        "paymentMethod": "card",
                        "paymentProductGroup": "cards",
                    ],
                    [
                        "allowsRecurring": true,
                        "allowsTokenization": true,
                        "displayHints": [
                            "displayOrder": 19,
                            "label": "American Express",
                            "logo": "/templates/master/global/css/img/ppimages/pp_logo_2_v1.png",
                        ],
                        "usesRedirectionTo3rdParty": false,
                        "id": 2,
                        "maxAmount": 1_000_000,
                        "mobileIntegrationLevel": "OPTIMISED_SUPPORT",
                        "paymentMethod": "card",
                        "paymentProductGroup": "cards",
                    ],
                    [
                        "allowsRecurring": true,
                        "allowsTokenization": true,
                        "displayHints": [
                            "displayOrder": 18,
                            "label": "MasterCard",
                            "logo": "/templates/master/global/css/img/ppimages/pp_logo_3_v1.png",
                        ],
                        "usesRedirectionTo3rdParty": false,
                        "id": 3,
                        "maxAmount": 1_000_000,
                        "mobileIntegrationLevel": "OPTIMISED_SUPPORT",
                        "paymentMethod": "card",
                        "paymentProductGroup": "cards",
                    ],
                ]
            ]
            return
                HTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        let context =
            PaymentContext(
                amountOfMoney: AmountOfMoney(totalAmount: 3, currencyCode: "EUR"),
                isRecurring: true,
                countryCode: "NL"
            )
        let expectation = self.expectation(description: "Response provided")

        communicator.paymentProducts(
            forContext: context,
            success: { _ in
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure while testing paymentProductForContext: \(error.localizedDescription)")
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }

    }

    func testPublicKey() {
        stub(condition: isHost("example.com")) { _ in
            let response = [
                "keyId": "86b64e4e-f43e-4a27-9863-9bbd5b499f82",
                // swiftlint:disable line_length
                "publicKey":
                    "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkiJlGL1QjUnGDLpMNBtZPYVtOU121jfFcV4WrZayfw9Ib/1AtPBHP/0ZPocdA23zDh6aB+QiOQEkHZlfnelBNnEzEu4ibda3nDdjSrKveSiQPyB5X+u/IS3CR48B/g4QJ+mcMV9hoFt6Hx3R99A0HWMs4um8elQsgB11MsLmGb1SuLo0S1pgL3EcckXfBDNMUBMQ9EtLC9zQW6Y0kx6GFXHgyjNb4yixXfjo194jfhei80sVQ49Y/SHBt/igATGN1l18IBDtO0eWmWeBckwbNkpkPLAvJfsfa3JpaxbXwg3rTvVXLrIRhvMYqTsQmrBIJDl7F6igPD98Y1FydbKe5QIDAQAB",
            ]
            // swiftlint:enable line_length
            return
                HTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        let expectation = self.expectation(description: "Response provided")

        communicator.publicKey(
            success: { (publicKeyResponse) in
                expectation.fulfill()

                XCTAssertEqual(
                    publicKeyResponse.keyId,
                    "86b64e4e-f43e-4a27-9863-9bbd5b499f82",
                    "Received keyId not as expected"
                )
                // swiftlint:disable line_length
                XCTAssertEqual(
                    publicKeyResponse.encodedPublicKey,
                    "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkiJlGL1QjUnGDLpMNBtZPYVtOU121jfFcV4WrZayfw9Ib/1AtPBHP/0ZPocdA23zDh6aB+QiOQEkHZlfnelBNnEzEu4ibda3nDdjSrKveSiQPyB5X+u/IS3CR48B/g4QJ+mcMV9hoFt6Hx3R99A0HWMs4um8elQsgB11MsLmGb1SuLo0S1pgL3EcckXfBDNMUBMQ9EtLC9zQW6Y0kx6GFXHgyjNb4yixXfjo194jfhei80sVQ49Y/SHBt/igATGN1l18IBDtO0eWmWeBckwbNkpkPLAvJfsfa3JpaxbXwg3rTvVXLrIRhvMYqTsQmrBIJDl7F6igPD98Y1FydbKe5QIDAQAB",
                    "Received publicKey not as expected"
                )
                // swiftlint:enable line_length
            },
            failure: { (error) in
                XCTFail("Unexpected failure while testing publicKey: \(error.localizedDescription)")
            }
        )
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testPaymentProductWithId() {
        stub(condition: isHost("example.com")) { _ in
            let response =
                [
                    "allowsRecurring": true,
                    "allowsTokenization": true,
                    "displayHints": [
                        "displayOrder": 20,
                        "label": "Visa",
                        "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png",
                    ],
                    "displayHintsList": [
                        [
                            "displayOrder": 20,
                            "label": "Visa",
                            "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png",
                        ]
                    ],
                    "usesRedirectionTo3rdParty": false,
                    "fields": [
                        [
                            "dataRestrictions": [
                                "isRequired": true,
                                "validators": [
                                    "length": [
                                        "maxLength": 19,
                                        "minLength": 12,
                                    ],
                                    "luhn": [

                                        ],
                                    "expirationDate": [

                                        ],
                                    "regularExpression": [
                                        "regularExpression": "(?:0[1-9]|1[0-2])[0-9]{2}"
                                    ],
                                ],
                            ],
                            "displayHints": [
                                "displayOrder": 10,
                                "formElement": [
                                    "type": "text"
                                ],
                                "label": "Card number:",
                                "mask": "{{9999}} {{9999}} {{9999}} {{9999}} {{999}}",
                                "obfuscate": false,
                                "placeholderLabel": "**** **** **** ****",
                                "preferredInputType": "IntegerKeyboard",
                            ],
                            "id": "cardNumber",
                            "type": "numericstring",
                        ]
                    ],
                    "id": 1,
                    "maxAmount": 1_000_000,
                    "mobileIntegrationLevel": "OPTIMISED_SUPPORT",
                    "paymentMethod": "card",
                    "paymentProductGroup": "cards",
                ] as [String: Any]
            return
                HTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        let expectation = self.expectation(description: "Response provided")

        communicator.paymentProduct(
            withIdentifier: "1",
            context: context,
            success: { (paymentProduct) in
                expectation.fulfill()

                let product = paymentProduct
                XCTAssertEqual(product.identifier, "1", "Received product id not as expected")
                XCTAssertEqual(
                    product.displayHints.first?.displayOrder,
                    20,
                    "Received product displayOrder not as expected"
                )
                XCTAssertEqual(
                    product.displayHints.first?.logoPath,
                    "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png",
                    "Received product logoPath not as expected"
                )

                guard let field = product.fields.paymentProductFields.first else {
                    XCTFail("Received product field not as expected")
                    return
                }
                // Data Restrictions
                XCTAssertEqual(
                    field.dataRestrictions.isRequired,
                    true,
                    "Received product field isRequired not as expected"
                )
                guard let lengthValidator = field.dataRestrictions.validators.validators[2] as? ValidatorLength else {
                    XCTFail("Received product field length validator not as expected")
                    return
                }

                XCTAssertEqual(
                    lengthValidator.maxLength,
                    19,
                    "Received product field length validator maxlength not as expected"
                )
                XCTAssertEqual(
                    lengthValidator.minLength,
                    12,
                    "Received product field length validator minLength not as expected"
                )
                XCTAssertEqual(
                    field.dataRestrictions.validators.validators.count,
                    4,
                    "Received product fields count not as expected"
                )

                // Display Hints
                XCTAssertEqual(
                    field.displayHints.displayOrder,
                    10,
                    "Received product field displayHints displayOrder not as expected"
                )
                XCTAssertEqual(
                    field.displayHints.mask,
                    "{{9999}} {{9999}} {{9999}} {{9999}} {{999}}",
                    "Received product field displayHints mask not as expected"
                )
                XCTAssertEqual(
                    field.displayHints.obfuscate,
                    false,
                    "Received product field displayHints obfuscate not as expected"
                )
                XCTAssertEqual(
                    field.displayHints.preferredInputType,
                    PreferredInputType.integerKeyboard,
                    "Received product field displayHints preferredInputType not as expected"
                )
                XCTAssertEqual(
                    field.displayHints.formElement.type,
                    FormElementType.textType,
                    "Received product field displayHints formElement type not as expected"
                )
            },
            failure: { (error) in
                XCTFail("Unexpected failure while testing paymentProductWithId: \(error.localizedDescription)")
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testPaymentProductIdByPartialCreditCardNumber() {
        stub(condition: isHost("example.com")) { _ in
            let response =
                [
                    "countryCode": "RU",
                    "paymentProductId": 3,
                ] as [String: Any]
            return
                HTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        let expectation = self.expectation(description: "Response provided")

        communicator.paymentProductId(
            byPartialCreditCardNumber: "520953",
            context: context,
            success: { (gciinDetailsResponse) in
                expectation.fulfill()

                XCTAssertEqual(gciinDetailsResponse.countryCode, "RU", "Received countrycode not as expected")
                XCTAssertEqual(gciinDetailsResponse.paymentProductId, "3", "Received paymentProductId not as expected")
            },
            failure: { (error) in
                XCTFail(
                    """
                    Unexpected failure while testing
                    paymentProductWithIdPartialCreditCard: \(error.localizedDescription)
                    """
                )
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testIINPartialCreditCardNumberLogic() {
        // Test that a partial CC of length 6 returns 6 IIN digits
        let result1 = communicator.getIINDigitsFrom(partialCreditCardNumber: "123456")
        XCTAssertEqual(result1, "123456", "Expected: '123456', actual: \(result1)")

        // Test that a partial CC of length 7 returns 6 IIN digits
        let result2 = communicator.getIINDigitsFrom(partialCreditCardNumber: "1234567")
        XCTAssertEqual(result2, "123456", "Expected: '123456', actual: \(result2)")

        // Test that a partial CC of length 8 returns 8 IIN digits
        let result3 = communicator.getIINDigitsFrom(partialCreditCardNumber: "12345678")
        XCTAssertEqual(result3, "12345678", "Expected: '12345678', actual: \(result3)")

        // Test that a partial CC of length less than 6 returns the provided digits
        let result4 = communicator.getIINDigitsFrom(partialCreditCardNumber: "123")
        XCTAssertEqual(result4, "123", "Expected: '123', actual: \(result4)")

        // Test that an empty string does not crash
        let result5 = communicator.getIINDigitsFrom(partialCreditCardNumber: "")
        XCTAssertEqual(result5, "", "Expected: '', actual: \(result5)")

        // Test that a partial CC longer than 8 returns 8 IIN digits
        let result6 = communicator.getIINDigitsFrom(partialCreditCardNumber: "12345678112")
        XCTAssertEqual(result6, "12345678", "Expected: '123456', actual: \(result6)")
    }

    func testFilteredPaymentProductList() {
        stub(condition: isHost("example.com")) {
            _ in
            let response: [String: Any] = [
                "paymentProducts": [
                    [
                        "id": Int(SDKConstants.kMaestroIdentifier)!,
                        "displayHintsList": [
                            [
                                "displayOrder": 1,
                                "label": "Maestro",
                                "logo": "https://example.com/maestro.png",
                            ]
                        ],
                        "paymentMethod": "card",
                        "usesRedirectionTo3rdParty": false,
                    ],
                    [
                        "id": Int(SDKConstants.kIntersolveIdentifier)!,
                        "displayHintsList": [
                            [
                                "displayOrder": 2,
                                "label": "Intersolve",
                                "logo": "https://example.com/intersolve.png",
                            ]
                        ],
                        "paymentMethod": "card",
                        "usesRedirectionTo3rdParty": false,
                    ],
                    [
                        "id": Int(SDKConstants.kSodexoSportCultureIdentifier)!,
                        "displayHintsList": [
                            [
                                "displayOrder": 3,
                                "label": "Sodexo Sport Culture",
                                "logo": "https://example.com/sodexo.png",
                            ]
                        ],
                        "paymentMethod": "card",
                        "usesRedirectionTo3rdParty": false,
                    ],
                    [
                        "id": Int(SDKConstants.kVVVGiftCardIdentifier)!,
                        "displayHintsList": [
                            [
                                "displayOrder": 4,
                                "label": "VVV Gift Card",
                                "logo": "https://example.com/vvv.png",
                            ]
                        ],
                        "paymentMethod": "card",
                        "usesRedirectionTo3rdParty": false,
                    ],
                    [
                        "id": 9999,
                        "displayHintsList": [
                            [
                                "displayOrder": 5,
                                "label": "Test Visible Product",
                                "logo": "https://example.com/testvisible.png",
                            ]
                        ],
                        "paymentMethod": "card",
                        "usesRedirectionTo3rdParty": false,
                    ],
                ]
            ]
            return HTTPStubsResponse(
                jsonObject: response,
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }

        let listExpectation = expectation(description: "Payment products filtered")

        communicator.paymentProducts(
            forContext: context,
            success: { paymentProducts in
                let ids = paymentProducts.paymentProducts.map { $0.identifier }

                XCTAssertFalse(ids.contains(SDKConstants.kMaestroIdentifier), "Maestro product should be filtered out")
                XCTAssertFalse(
                    ids.contains(SDKConstants.kIntersolveIdentifier),
                    "Intersolve product should be filtered out"
                )
                XCTAssertFalse(
                    ids.contains(SDKConstants.kSodexoSportCultureIdentifier),
                    "Sodexo Sport & Culture product should be filtered out"
                )
                XCTAssertFalse(
                    ids.contains(SDKConstants.kVVVGiftCardIdentifier),
                    "VVV Giftcard product should be filtered out"
                )
                XCTAssertTrue(ids.contains("9999"), "Test Product should be present")
                listExpectation.fulfill()
            },
            failure: { error in
                XCTFail("Failed to fetch payment products: \(error.localizedDescription)")
                listExpectation.fulfill()
            }
        )

        wait(for: [listExpectation], timeout: 5)
    }

    func testPaymentProductWithFilteredId() {
        let filteredIds = SDKConstants.unsupportedPaymentProducts
        let expectation = self.expectation(
            description: "Unsupported products should trigger immediate failure in paymentProduct"
        )
        expectation.expectedFulfillmentCount = filteredIds.count

        for id in filteredIds {
            communicator.paymentProduct(
                withIdentifier: id,
                context: context,
                success: { _ in
                    XCTFail("Success should not be called for unsupported product ids")
                    expectation.fulfill()
                },
                failure: { error in
                    if case let SessionError.RuntimeError(message) = error {
                        XCTAssertEqual(message, "Response was empty.", "Error message doed not match expected")
                    } else {
                        XCTFail("Failure called with unexpected error type: \(error)")
                    }
                    expectation.fulfill()
                }
            )
        }

        wait(for: [expectation], timeout: 5)
    }

}
