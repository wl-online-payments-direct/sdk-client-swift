/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest

@testable import OnlinePaymentsKit

class OnlinePaymentSdkTests: XCTestCase {
    let host = "example.com"

    var sdk: OnlinePaymentsSdk!

    let sessionData = SessionData(
        clientSessionId: "client-session-id",
        customerId: "customer-id",
        clientApiUrl: "https://example.com",
        assetUrl: "https://example.com/assets"
    )

    let context = PaymentContext(
        amountOfMoney: AmountOfMoney(amount: 3, currencyCode: "EUR"),
        isRecurring: true,
        countryCode: "NL"
    )

    override func setUp() {
        super.setUp()

        let config = SdkConfiguration(
            appIdentifier: "test-app",
        )

        sdk = try! OnlinePaymentsSdk(
            sessionData: sessionData,
            configuration: config
        )
    }

    override func tearDown() {
        sdk = nil
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testGetBasicPaymentProducts() {
        Stubs.stubWithFixture(
            "basicPaymentProducts",
            condition: isHost(host) && isPath("/client/v1/customer-id/products") && isMethodGET()
        )

        let expectation = self.expectation(description: "Response provided")

        sdk.basicPaymentProducts(
            forContext: context,
            success: { products in
                XCTAssertNotNil(products)
                XCTAssertFalse(products.paymentProducts.isEmpty)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure: \(error.message)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testGetBasicPaymentProductsFiltersUnsupportedProducts() {
        stub(condition: isHost(host) && isPath("/client/v1/customer-id/products") && isMethodGET()) { _ in
            let response = [
                "paymentProducts": [
                    [
                        "id": SupportedProductsUtil.kMaestroIdentifier,
                        "displayHints": [
                            "displayOrder": 1,
                            "label": "Maestro",
                            "logo": "https://example.com/maestro.png",
                        ],
                        "paymentMethod": "card",
                        "usesRedirectionTo3rdParty": false,
                    ],
                    [
                        "id": 9999,
                        "displayHints": [
                            "displayOrder": 2,
                            "label": "Test Product",
                            "logo": "https://example.com/test.png",
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

        let expectation = self.expectation(description: "Filters unsupported products")

        sdk.basicPaymentProducts(
            forContext: context,
            success: { products in
                let ids = products.paymentProducts.map { $0.id }
                XCTAssertFalse(ids.contains(SupportedProductsUtil.kMaestroIdentifier), "Maestro should be filtered out")
                XCTAssertTrue(ids.contains(9999), "Test product should be present")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3)
    }

    func testGetPaymentProduct() {
        Stubs.stubWithFixture(
            "cardPaymentProduct",
            condition: isHost(host) && isPath("/client/v1/customer-id/products/1") && isMethodGET()
        )

        let expectation = self.expectation(description: "Get payment product")

        sdk.paymentProduct(
            withId: 1,
            paymentContext: context,
            success: { product in
                XCTAssertEqual(product.id, 1)
                XCTAssertEqual(product.label, "VISA")
                XCTAssertFalse(product.fields.isEmpty)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure: \(error.message)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3)
    }

    func testGetPaymentProductNetworks() {
        let productID = 1

        Stubs.stubWithFixture(
            "paymentProductNetworks",
            condition: isHost(host) && isPath("/client/v1/customer-id/products/\(productID)/networks") && isMethodGET()
        )

        let expectation = self.expectation(description: "Get networks")

        sdk.paymentProductNetworks(
            forProductId: productID,
            paymentContext: context,
            success: { networks in
                XCTAssertFalse(networks.paymentProductNetworks.isEmpty)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure: \(error.message)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3)
    }

    func testGetIinDetailsForTooShortNumber() {
        let expectation = self.expectation(description: "Too short number")

        sdk.iinDetails(
            forPartialCardNumber: "01234",
            paymentContext: context,
            success: { response in
                XCTAssertEqual(response.status, IINStatus.notEnoughDigits)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )

        waitForExpectations(timeout: 3)
    }

    func testGetIinDetailsForValidNumber() {
        Stubs.stubWithFixture(
            "iinDetailsResponse",
            condition: isHost(host) && isPath("/client/v1/customer-id/services/getIINdetails") && isMethodPOST()
        )

        let expectation = self.expectation(description: "Valid number")

        sdk.iinDetails(
            forPartialCardNumber: "012345",
            paymentContext: context,
            success: { response in
                XCTAssertEqual(response.status, IINStatus.supported)
                XCTAssertEqual(response.countryCode, "BE")
                XCTAssertEqual(response.paymentProductId, 1)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure: \(error.message)")
            }
        )

        waitForExpectations(timeout: 3)
    }

    func testGetPublicKey() {
        Stubs.stubWithFixture(
            "publicKeyResponse",
            condition: isHost(host) && isPath("/client/v1/customer-id/crypto/publickey") && isMethodGET()
        )

        let expectation = self.expectation(description: "Get public key")

        sdk.publicKey(
            success: { publicKeyResponse in
                XCTAssertEqual(publicKeyResponse.keyId, "12345678-aaaa-bbbb-cccc-876543218765")
                XCTAssertNotNil(publicKeyResponse.publicKey)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure: \(error.message)")
            }
        )

        waitForExpectations(timeout: 3)
    }

    func testGetSurchargeCalculationWithCard() {
        Stubs.stubWithFixture(
            "surchargeCalculationResponse",
            condition: isHost(host) && isPath("/client/v1/customer-id/services/surchargecalculation") && isMethodPOST()
        )

        let expectation = self.expectation(description: "Surcharge calculation")

        let amountOfMoney = AmountOfMoney(amount: 100, currencyCode: "EUR")

        sdk.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            partialCardNumber: "424242",
            paymentProductId: NSNumber(value: 1),
            success: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response.surcharges.count, 1)
                XCTAssertEqual(response.surcharges[0].paymentProductId, 1)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure: \(error.message)")
            }
        )

        waitForExpectations(timeout: 3)
    }

    func testGetSurchargeCalculationWithToken() {
        Stubs.stubWithFixture(
            "surchargeCalculationResponse",
            condition: isHost(host) && isPath("/client/v1/customer-id/services/surchargecalculation") && isMethodPOST()
        )

        let expectation = self.expectation(description: "Surcharge calculation with token")

        let amountOfMoney = AmountOfMoney(amount: 100, currencyCode: "EUR")

        sdk.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            token: "test-token",
            success: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response.surcharges.count, 1)
                XCTAssertEqual(response.surcharges[0].paymentProductId, 1)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure: \(error.message)")
            }
        )

        waitForExpectations(timeout: 3)
    }

    func testEncryptPaymentRequest() {
        Stubs.stubWithFixture(
            "publicKeyResponse",
            condition: isHost(host) && isPath("/client/v1/customer-id/crypto/publickey") && isMethodGET()
        )
        Stubs.stubWithFixture(
            "cardPaymentProduct",
            condition: isHost(host) && isPath("/client/v1/customer-id/products/1") && isMethodGET()
        )

        let expectation = self.expectation(description: "Encrypt payment request")

        // First get the payment product
        sdk.paymentProduct(
            withId: 1,
            paymentContext: context,
            success: { paymentProduct in
                let paymentRequest = PaymentRequest(paymentProduct: paymentProduct)
                try! paymentRequest.setValue(id: "cardNumber", value: "4242424242424242")
                try! paymentRequest.setValue(id: "cvv", value: "123")
                try! paymentRequest.setValue(id: "cardholderName", value: "John Doe")
                try! paymentRequest.setValue(id: "expiryDate", value: "122030")
                paymentRequest.tokenize = false

                self.sdk.encryptPaymentRequest(
                    paymentRequest,
                    success: { encryptedRequest in
                        XCTAssertNotNil(encryptedRequest.encryptedCustomerInput)
                        XCTAssertFalse(encryptedRequest.encryptedCustomerInput.isEmpty)
                        XCTAssertNotNil(encryptedRequest.encodedClientMetaInfo)
                        XCTAssertFalse(encryptedRequest.encodedClientMetaInfo.isEmpty)
                        expectation.fulfill()
                    },
                    failure: { error in
                        XCTFail("Unexpected failure: \(error.message)")
                    }
                )
            },
            failure: { error in
                XCTFail("Failed to get payment product: \(error.message)")
            }
        )

        waitForExpectations(timeout: 5)
    }

    func testEncryptTokenRequest() {
        Stubs.stubWithFixture(
            "publicKeyResponse",
            condition: isHost(host) && isPath("/client/v1/customer-id/crypto/publickey") && isMethodGET()
        )

        let expectation = self.expectation(description: "Encrypt token request")

        let tokenRequest = CreditCardTokenRequest()
        tokenRequest.cardNumber = "4242424242424242"
        tokenRequest.securityCode = "123"
        tokenRequest.expiryDate = "1225"
        tokenRequest.paymentProductId = NSNumber(value: 1)

        sdk.encryptTokenRequest(
            tokenRequest,
            success: { encryptedRequest in
                XCTAssertNotNil(encryptedRequest.encryptedCustomerInput)
                XCTAssertFalse(encryptedRequest.encryptedCustomerInput.isEmpty)
                XCTAssertNotNil(encryptedRequest.encodedClientMetaInfo)
                XCTAssertFalse(encryptedRequest.encodedClientMetaInfo.isEmpty)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure: \(error.message)")
            }
        )

        waitForExpectations(timeout: 5)
    }

    func testGetCurrencyConversionQuoteWithCard() {
        Stubs.stubWithFixture(
            "currencyConversionResponse",
            condition: isHost(host) && isPath("/client/v1/customer-id/services/dccrate") && isMethodPOST()
        )

        let expectation = self.expectation(description: "Currency conversion")

        let amountOfMoney = AmountOfMoney(amount: 100, currencyCode: "EUR")

        sdk.currencyConversionQuote(
            amountOfMoney: amountOfMoney,
            partialCardNumber: "424242",
            paymentProductId: NSNumber(value: 1),
            success: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response.dccSessionId, "5cd02469177743fb8a0b2c78937ee25f")
                XCTAssertEqual(response.proposal.rate.exchangeRate, 1.57)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure: \(error.message)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3)
    }

    func testGetCurrencyConversionQuoteWithToken() {
        Stubs.stubWithFixture(
            "currencyConversionResponse",
            condition: isHost(host) && isPath("/client/v1/customer-id/services/dccrate") && isMethodPOST()
        )

        let expectation = self.expectation(description: "Currency conversion with token")

        let amountOfMoney = AmountOfMoney(amount: 100, currencyCode: "EUR")

        sdk.currencyConversionQuote(
            amountOfMoney: amountOfMoney,
            token: "test-token",
            success: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response.dccSessionId, "5cd02469177743fb8a0b2c78937ee25f")
                XCTAssertEqual(response.proposal.rate.exchangeRate, 1.57)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure: \(error.message)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3)
    }
}
