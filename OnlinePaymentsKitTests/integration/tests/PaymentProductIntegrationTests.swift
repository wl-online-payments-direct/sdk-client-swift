/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import XCTest

@testable import OnlinePaymentsKit

/// Integration tests for getPaymentProduct.
/// Tests real API calls to the preprod environment.
class PaymentProductIntegrationTests: BaseIntegrationTest {

    private let visaProductId = 1  // VISA

    func testGetPaymentProduct_WhenCalledAgain_ReturnsCachedResult() {
        let firstExpectation = expectation(description: "First call")
        let secondExpectation = expectation(description: "Second call")

        sdk.paymentProduct(
            withId: visaProductId,
            paymentContext: paymentContext,
            success: { firstResult in
                firstExpectation.fulfill()

                self.sdk.paymentProduct(
                    withId: self.visaProductId,
                    paymentContext: self.paymentContext,
                    success: { secondResult in
                        XCTAssertEqual(firstResult.id, secondResult.id, "Cached result should have same product ID")
                        XCTAssertEqual(firstResult.fields.count, secondResult.fields.count, "Cached result should have same fields")
                        secondExpectation.fulfill()
                    },
                    failure: { error in
                        XCTFail("Second call should not fail: \(error)")
                        secondExpectation.fulfill()
                    }
                )
            },
            failure: { error in
                XCTFail("First call should not fail: \(error)")
                firstExpectation.fulfill()
                secondExpectation.fulfill()
            }
        )

        waitForExpectations(timeout: 15.0)
    }

    func testGetPaymentProduct_UnsupportedProductIds_ThrowsResponseError() {
        for productId in SupportedProductsUtil.sdkUnsupportedProducts {
            let productExpectation = expectation(description: "Get unsupported product \(productId)")

            sdk.paymentProduct(
                withId: productId,
                paymentContext: paymentContext,
                success: { _ in
                    XCTFail("Should not succeed for SDK-unsupported product \(productId)")
                    productExpectation.fulfill()
                },
                failure: { error in
                    XCTAssertTrue(
                        error is ResponseError,
                        "Error should be a ResponseError for unsupported product \(productId)"
                    )
                    if let responseError = error as? ResponseError {
                        XCTAssertEqual(
                            404,
                            responseError.httpStatusCode,
                            "HTTP status code should be 404 for unsupported product \(productId)"
                        )
                        if let errorId = responseError.metadata?["errorId"] as? String {
                            XCTAssertEqual(
                                "48b78d2d-1b35-4f8b-92cb-57cc2638e901",
                                errorId,
                                "Error ID should match for unsupported product \(productId)"
                            )
                        }
                    }

                    productExpectation.fulfill()
                }
            )

            waitForExpectations(timeout: 5.0)
        }
    }

    func testGetPaymentProduct_ValidProductId_ResponseContainsAccountsOnFile() {
        let encryptExpectation = expectation(description: "Encrypt payment request")
        let productExpectation = expectation(description: "Get product with AOF")

        // Step 1: Fetch product and encrypt a request to obtain encrypted customer input
        sdk.paymentProduct(
            withId: visaProductId,
            paymentContext: paymentContext,
            success: { paymentProduct in
                let request = PaymentRequest(paymentProduct: paymentProduct)
                do {
                    try request.setValue(id: "cardNumber", value: "4242424242424242")
                    try request.setValue(id: "cardholderName", value: "Test Cardholder")
                    try request.setValue(id: "cvv", value: "123")
                    try request.setValue(id: "expiryDate", value: "1230")
                } catch {
                    XCTFail("Failed to set field values: \(error)")
                    encryptExpectation.fulfill()
                    productExpectation.fulfill()

                    return
                }

                // Step 2: Encrypt to get encrypted customer input for token creation
                self.sdk.encryptPaymentRequest(
                    request,
                    success: { encryptedRequest in
                        encryptExpectation.fulfill()

                        // Step 3: Create a token via server API
                        let tokenRequest = CreateTokenRequest(
                            encryptedCustomerInput: encryptedRequest.encryptedCustomerInput
                        )
                        self.serverApi.createToken(request: tokenRequest) { tokenResult in
                            switch tokenResult {
                            case .failure(let error):
                                XCTFail("Token creation failed: \(error)")
                                productExpectation.fulfill()

                            case .success(let tokenResponse):
                                guard let token = tokenResponse.token else {
                                    XCTFail("Token should not be nil")
                                    productExpectation.fulfill()

                                    return
                                }

                                // Step 4: Create a new session that includes the token
                                let sessionRequest = CreateSessionRequest(tokens: [token])
                                self.serverApi.createSession(request: sessionRequest) { sessionResult in
                                    switch sessionResult {
                                    case .failure(let error):
                                        XCTFail("Session creation failed: \(error)")
                                        productExpectation.fulfill()

                                    case .success(let sessionResponse):
                                        guard
                                            let clientSessionId = sessionResponse.clientSessionId,
                                            let customerId = sessionResponse.customerId,
                                            let clientApiUrl = sessionResponse.clientApiUrl,
                                            let assetUrl = sessionResponse.assetUrl
                                        else {
                                            XCTFail("Invalid session response")
                                            productExpectation.fulfill()

                                            return
                                        }

                                        // Step 5: Init a new SDK instance with the token-bearing session
                                        let sessionData = SessionData(
                                            clientSessionId: clientSessionId,
                                            customerId: customerId,
                                            clientApiUrl: clientApiUrl,
                                            assetUrl: assetUrl
                                        )
                                        guard let sdkWithAof = try? OnlinePaymentsSdk(
                                            sessionData: sessionData,
                                            configuration: SdkConfiguration(
                                                appIdentifier: "SwiftSDK/IntegrationTests"
                                            )
                                        ) else {
                                            XCTFail("Failed to create SDK with token session")
                                            productExpectation.fulfill()

                                            return
                                        }

                                        // Step 6: Fetch product and assert accounts on file are present
                                        sdkWithAof.paymentProduct(
                                            withId: self.visaProductId,
                                            paymentContext: self.paymentContext,
                                            success: { productWithAof in
                                                XCTAssertFalse(
                                                    productWithAof.accountsOnFile.isEmpty,
                                                    "Product should have at least one account on file"
                                                )
                                                productExpectation.fulfill()
                                            },
                                            failure: { error in
                                                XCTFail("Should not fail fetching product with AOF: \(error)")
                                                productExpectation.fulfill()
                                            }

                                        )
                                    }
                                }
                            }
                        }
                    },
                    failure: { error in
                        XCTFail("Encryption should not fail: \(error)")
                        encryptExpectation.fulfill()
                        productExpectation.fulfill()
                    }
                )
            },
            failure: { error in
                XCTFail("Should not fail getting initial product: \(error)")
                encryptExpectation.fulfill()
                productExpectation.fulfill()
            }
        )

        waitForExpectations(timeout: 30.0)
    }
}
