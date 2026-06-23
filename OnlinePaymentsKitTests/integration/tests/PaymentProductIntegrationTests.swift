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

import XCTest

@testable import OnlinePaymentsKit

/// Integration tests for getPaymentProduct.
/// Tests real API calls to the preprod environment.
class PaymentProductIntegrationTests: BaseIntegrationTest {

    private let visaProductId = 1

    func testGetPaymentProduct_shouldReturnPaymentProductForValidContext() {
        let expectation = expectation(description: "Get payment product")

        sdk.paymentProduct(
            withId: visaProductId,
            paymentContext: paymentContext,
            success: { paymentProduct in
                XCTAssertEqual(
                    self.visaProductId,
                    paymentProduct.id,
                    "Product ID should match requested ID"
                )

                XCTAssertFalse(
                    paymentProduct.fields.isEmpty,
                    "Payment product should have fields"
                )

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetPaymentProduct_calledTwice_shouldUseCacheOnSecondCall() {
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
                        XCTAssertEqual(
                            firstResult.id,
                            secondResult.id,
                            "Cached result should have same product ID"
                        )

                        XCTAssertEqual(
                            firstResult.fields.count,
                            secondResult.fields.count,
                            "Cached result should have same fields"
                        )

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

    func testGetPaymentProduct_shouldReturnProductWithDisplayHints() {
        let expectation = expectation(description: "Get payment product with display hints")

        sdk.paymentProduct(
            withId: visaProductId,
            paymentContext: paymentContext,
            success: { paymentProduct in
                XCTAssertNotNil(paymentProduct.logo, "Payment product should have a logo")
                XCTAssertFalse(
                    paymentProduct.logo?.isEmpty ?? true,
                    "Payment product logo should not be empty"
                )

                XCTAssertGreaterThanOrEqual(
                    paymentProduct.displayOrder,
                    0,
                    "Payment product should have a valid display order"
                )

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetPaymentProduct_shouldReturnProductWithMappedAccountsOnFile() {
        let encryptExpectation = expectation(description: "Encrypt payment request")
        let productExpectation = expectation(description: "Get product with accounts on file")

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

                                        guard let sdkWithAccountOnFile = try? OnlinePaymentsSdk(
                                            sessionData: sessionData,
                                            configuration: SdkConfiguration(
                                                appIdentifier: "SwiftSDK/IntegrationTests"
                                            )
                                        ) else {
                                            XCTFail("Failed to create SDK with account-on-file session")
                                            productExpectation.fulfill()

                                            return
                                        }
                                        // Step 6: Fetch product and assert accounts on file are present
                                        sdkWithAccountOnFile.paymentProduct(
                                            withId: self.visaProductId,
                                            paymentContext: self.paymentContext,
                                            success: { productWithAccountOnFile in
                                                XCTAssertFalse(
                                                    productWithAccountOnFile.accountsOnFile.isEmpty,
                                                    "Product should have at least one account on file"
                                                )

                                                let accountOnFile = productWithAccountOnFile.accountsOnFile.first
                                                XCTAssertNotNil(
                                                    accountOnFile?.id,
                                                    "Mapped account on file should have an ID"
                                                )

                                                productExpectation.fulfill()
                                            },
                                            failure: { error in
                                                XCTFail("Should not fail fetching product with account on file: \(error)")
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

    func testGetPaymentProduct_shouldReturnProductWithValidFieldStructure() {
        let expectation = expectation(description: "Get payment product with valid field structure")

        sdk.paymentProduct(
            withId: visaProductId,
            paymentContext: paymentContext,
            success: { paymentProduct in
                XCTAssertFalse(
                    paymentProduct.fields.isEmpty,
                    "Payment product should have fields"
                )

                let fieldIds = paymentProduct.fields.map { $0.id }

                XCTAssertTrue(
                    fieldIds.contains("cardNumber"),
                    "Card product should have cardNumber field"
                )

                XCTAssertTrue(
                    fieldIds.contains("expiryDate"),
                    "Card product should have expiryDate field"
                )

                XCTAssertTrue(
                    fieldIds.contains("cvv"),
                    "Card product should have cvv field"
                )

                XCTAssertTrue(
                    fieldIds.contains("cardholderName"),
                    "Card product should have cardholderName field"
                )

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetPaymentProduct_withUnsupportedOrMissingPaymentProduct_shouldReturnError() {
        let nonExistentProductId = 99999

        let expectation = expectation(description: "Get unsupported or missing payment product")

        sdk.paymentProduct(
            withId: nonExistentProductId,
            paymentContext: paymentContext,
            success: { _ in
                XCTFail("Should fail for unsupported or missing payment product")
                expectation.fulfill()
            },
            failure: { error in
                let responseError = error as? ResponseError

                XCTAssertNotNil(responseError, "Error should be a ResponseError")
                XCTAssertTrue(
                    (responseError?.httpStatusCode ?? 0) >= 400,
                    "Unsupported or missing product should return an error status"
                )

                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testPaymentProduct_unsupportedProduct_shouldReturnError() {
        XCTAssertFalse(
            SupportedProductsUtil.sdkUnsupportedProducts.isEmpty,
            "SDK unsupported products list should not be empty"
        )

        let expectations = SupportedProductsUtil.sdkUnsupportedProducts.map { productId in
            expectation(description: "Get SDK unsupported product \(productId)")
        }

        for (index, productId) in SupportedProductsUtil.sdkUnsupportedProducts.enumerated() {
            sdk.paymentProduct(
                withId: productId,
                paymentContext: paymentContext,
                success: { _ in
                    XCTFail("Should not succeed for SDK unsupported product \(productId)")
                    expectations[index].fulfill()
                },
                failure: { error in
                    let responseError = error as? ResponseError

                    XCTAssertNotNil(
                        responseError,
                        "Error should be a ResponseError for unsupported product \(productId)"
                    )

                    XCTAssertEqual(
                        404,
                        responseError?.httpStatusCode,
                        "HTTP status code should be 404 for unsupported product \(productId)"
                    )

                    expectations[index].fulfill()
                }
            )
        }

        waitForExpectations(timeout: 10.0)
    }

    func testGetPaymentProduct_withDifferentContext_shouldInvalidateCache() {
        let firstExpectation = expectation(description: "First call")
        let secondExpectation = expectation(description: "Second call")

        sdk.paymentProduct(
            withId: visaProductId,
            paymentContext: paymentContext,
            success: { firstResult in
                firstExpectation.fulfill()

                let usdContext = self.createPaymentContext(amount: 1000, currencyCode: "USD")

                self.sdk.paymentProduct(
                    withId: self.visaProductId,
                    paymentContext: usdContext,
                    success: { secondResult in
                        XCTAssertEqual(
                            firstResult.id,
                            secondResult.id,
                            "Both contexts should return the same requested product ID"
                        )

                        XCTAssertFalse(
                            firstResult === secondResult,
                            "Different contexts should yield distinct response objects"
                        )

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
}
