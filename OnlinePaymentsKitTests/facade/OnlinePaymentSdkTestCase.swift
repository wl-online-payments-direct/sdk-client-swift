/*
 * Do not remove or alter the notices in this preamble.
 *
 * This software is owned by Worldline and may not be be altered, copied, reproduced, republished, uploaded, posted, transmitted or distributed in any way, without the prior written consent of Worldline.
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

class OnlinePaymentSdkTestCase: XCTestCase {
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

    override func setUpWithError() throws {
        try super.setUpWithError()

        let config = SdkConfiguration(
            appIdentifier: "test-app",
        )

        sdk = try OnlinePaymentsSdk(
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
                XCTAssertFalse(products.paymentProducts.isEmpty)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure: \(error.message)")
                expectation.fulfill()
            }

        )

        waitForExpectations(timeout: 3)
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

    func testGetBasicPaymentProducts_allProductsFilteredOut_shouldReturnError() {
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
                    ]
                ]
            ]

            return HTTPStubsResponse(
                jsonObject: response,
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }

        let expectation = self.expectation(description: "All products filtered out returns error")

        sdk.basicPaymentProducts(
            forContext: context,
            success: { _ in
                XCTFail("Should have failed when all products are filtered out")
                expectation.fulfill()
            },
            failure: { error in
                let responseError = error as? ResponseError
                XCTAssertNotNil(responseError, "Error should be a ResponseError")
                XCTAssertEqual(responseError?.httpStatusCode, 404, "Should return 404 when no products remain")
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
                expectation.fulfill()
            }

        )

        waitForExpectations(timeout: 3)
    }

    func testGetIinDetailsReturnsUnknownWhenServerReturns404() {
        // When IIN endpoint returns 404, ApiClient treats it as a valid response (additionalAcceptableStatusCodes)
        // and decodes the body. An empty body (no paymentProductId) maps to status = .unknown.
        stub(
            condition: isHost(host) && isPath("/client/v1/customer-id/services/getIINdetails") && isMethodPOST()
        ) { _ in

            return HTTPStubsResponse(data: "{}".data(using: .utf8)!, statusCode: 404, headers: nil)
        }

        let expectation = self.expectation(description: "IIN 404 maps to unknown")

        sdk.iinDetails(
            forPartialCardNumber: "012345",
            paymentContext: context,
            success: { response in
                XCTAssertEqual(response.status, IINStatus.unknown, "404 response with no productId should map to .unknown")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail for 404 — it is an additionalAcceptableStatusCode: \(error.message)")
                expectation.fulfill()
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

    func testSurchargeCalculationUsesCache() {
        let bundle = Bundle(for: AnyTestBundleMarker.self)
        let url = bundle.url(forResource: "surchargeCalculationResponse", withExtension: "json")!
        let json = try! JSONSerialization.jsonObject(with: Data(contentsOf: url))

        var hitCount = 0
        stub(condition: isHost(host) && isPath("/client/v1/customer-id/services/surchargecalculation") && isMethodPOST()) { _ in
            hitCount += 1
            if hitCount > 1 {
                XCTFail("Cache miss — stub hit \(hitCount) times; second call should have been served from cache")
            }
            return HTTPStubsResponse(jsonObject: json, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        let amountOfMoney = AmountOfMoney(amount: 100, currencyCode: "EUR")
        let firstExpectation = expectation(description: "First surcharge call succeeds")
        let secondExpectation = expectation(description: "Second surcharge call uses cache")

        sdk.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            partialCardNumber: "424242",
            paymentProductId: NSNumber(value: 1),
            success: { _ in
                firstExpectation.fulfill()

                self.sdk.surchargeCalculation(
                    amountOfMoney: amountOfMoney,
                    partialCardNumber: "424242",
                    paymentProductId: NSNumber(value: 1),
                    success: { _ in
                        secondExpectation.fulfill()
                    },
                    failure: { error in
                        XCTFail("Second surcharge call should not fail: \(error.message)")
                        secondExpectation.fulfill()
                    }
                )
            },
            failure: { error in
                XCTFail("First surcharge call should not fail: \(error.message)")
                firstExpectation.fulfill()
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
                                XCTAssertFalse(encryptedRequest.encryptedCustomerInput.isEmpty)
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
        tokenRequest.expiryDate = "1230"
        tokenRequest.paymentProductId = NSNumber(value: 1)

        sdk.encryptTokenRequest(
            tokenRequest,
            success: { encryptedRequest in
                XCTAssertFalse(encryptedRequest.encryptedCustomerInput.isEmpty)
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

    func testCurrencyConversionQuoteUsesCache() {
        let bundle = Bundle(for: AnyTestBundleMarker.self)
        let url = bundle.url(forResource: "currencyConversionResponse", withExtension: "json")!
        let json = try! JSONSerialization.jsonObject(with: Data(contentsOf: url))

        var hitCount = 0
        stub(condition: isHost(host) && isPath("/client/v1/customer-id/services/dccrate") && isMethodPOST()) { _ in
            hitCount += 1
            if hitCount > 1 {
                XCTFail("Cache miss — stub hit \(hitCount) times; second call should have been served from cache")
            }
            return HTTPStubsResponse(jsonObject: json, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        let amountOfMoney = AmountOfMoney(amount: 100, currencyCode: "EUR")
        let firstExpectation = expectation(description: "First DCC call succeeds")
        let secondExpectation = expectation(description: "Second DCC call uses cache")

        sdk.currencyConversionQuote(
            amountOfMoney: amountOfMoney,
            partialCardNumber: "424242",
            paymentProductId: NSNumber(value: 1),
            success: { _ in
                firstExpectation.fulfill()

                self.sdk.currencyConversionQuote(
                    amountOfMoney: amountOfMoney,
                    partialCardNumber: "424242",
                    paymentProductId: NSNumber(value: 1),
                    success: { _ in
                        secondExpectation.fulfill()
                    },
                    failure: { error in
                        XCTFail("Second DCC call should not fail: \(error.message)")
                        secondExpectation.fulfill()
                    }
                )
            },
            failure: { error in
                XCTFail("First DCC call should not fail: \(error.message)")
                firstExpectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3)
    }

    func testConstructorCreatesInstance() throws {
        let instance = try OnlinePaymentsSdk(sessionData: sessionData)
        XCTAssertNotNil(instance)
    }

    func testConstructorWithConfigurationCreatesInstance() throws {
        let config = SdkConfiguration(appIdentifier: "test-app")
        let instance = try OnlinePaymentsSdk(sessionData: sessionData, configuration: config)
        XCTAssertNotNil(instance)
    }

    func testConstructorNormalizesSessionData() throws {
        let sessionWithTrailingSlash = SessionData(
            clientSessionId: "client-session-id",
            customerId: "customer-id",
            clientApiUrl: "https://example.com/",
            assetUrl: "https://example.com/assets"
        )

        let normalizedSdk = try OnlinePaymentsSdk(sessionData: sessionWithTrailingSlash)

        Stubs.stubWithFixture(
            "basicPaymentProducts",
            condition: isHost(host) && isPath("/client/v1/customer-id/products") && isMethodGET()
        )

        let expectation = self.expectation(description: "Normalized URL is used")

        normalizedSdk.basicPaymentProducts(
            forContext: context,
            success: { products in
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Normalized SDK should work: \(error.message)")
                expectation.fulfill()
            }

        )

        waitForExpectations(timeout: 3)
    }

    func testGetPaymentProductPropagatesFailure() {
        stub(condition: isHost(host) && isPath("/client/v1/customer-id/products/1") && isMethodGET()) { _ in

            return HTTPStubsResponse(
                error: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
            )
        }

        let expectation = self.expectation(description: "Failure propagated")

        sdk.paymentProduct(
            withId: 1,
            paymentContext: context,
            success: { _ in
                XCTFail("Should not succeed when service fails")
                expectation.fulfill()
            },
            failure: { error in
                expectation.fulfill()
            }

        )

        waitForExpectations(timeout: 3)
    }

    func testEncryptPaymentRequestPropagatesFailure() {
        Stubs.stubWithFixture(
            "cardPaymentProduct",
            condition: isHost(host) && isPath("/client/v1/customer-id/products/1") && isMethodGET()
        )
        stub(condition: isHost(host) && isPath("/client/v1/customer-id/crypto/publickey") && isMethodGET()) { _ in

            return HTTPStubsResponse(
                error: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
            )
        }

        let expectation = self.expectation(description: "Failure propagated")

        sdk.paymentProduct(
            withId: 1,
            paymentContext: context,
            success: { paymentProduct in
                let request = PaymentRequest(paymentProduct: paymentProduct)
                try! request.setValue(id: "cardNumber", value: "4242424242424242")
                try! request.setValue(id: "cvv", value: "123")
                try! request.setValue(id: "cardholderName", value: "John Doe")
                try! request.setValue(id: "expiryDate", value: "122030")

                self.sdk.encryptPaymentRequest(
                    request,
                    success: { _ in
                        XCTFail("Should not succeed when service fails")
                        expectation.fulfill()
                    },
                    failure: { error in
                                expectation.fulfill()
                    }

                )
            },
            failure: { error in
                XCTFail("Failed to get payment product: \(error.message)")
                expectation.fulfill()
            }

        )

        waitForExpectations(timeout: 5)
    }

    func testGetPublicKeyPropagatesFailure() {
        stub(condition: isHost(host) && isPath("/client/v1/customer-id/crypto/publickey") && isMethodGET()) { _ in

            return HTTPStubsResponse(
                error: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
            )
        }

        let expectation = self.expectation(description: "Failure propagated")

        sdk.publicKey(
            success: { _ in
                XCTFail("Should not succeed when service fails")
                expectation.fulfill()
            },
            failure: { error in
                expectation.fulfill()
            }

        )

        waitForExpectations(timeout: 3)
    }
}
