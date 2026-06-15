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
import OHHTTPStubs
import OHHTTPStubsSwift

@testable import OnlinePaymentsKit

/// Integration tests for payment request encryption.
/// Tests real encryption with actual public keys from the preprod environment.
class PaymentRequestIntegrationTests: BaseIntegrationTest {

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testEncryptPaymentRequest_withValidData_shouldReturnEncryptedData() {
        let getProductExpectation = expectation(description: "Get payment product")
        let encryptExpectation = expectation(description: "Encrypt payment request")

        // Get a payment product
        let productId = 1  // VISA
        sdk.paymentProduct(
            withId: productId,
            paymentContext: paymentContext,
            success: { paymentProduct in
                getProductExpectation.fulfill()

                // Create payment request
                let paymentRequest = PaymentRequest(paymentProduct: paymentProduct)
                do {
                    try paymentRequest.setValue(id: "cardNumber", value: "4567350000427977")
                    try paymentRequest.setValue(id: "cardholderName", value: "Test Cardholder")
                    try paymentRequest.setValue(id: "cvv", value: "123")
                    try paymentRequest.setValue(id: "expiryDate", value: "1230")

                    // Encrypt the request
                    self.sdk.encryptPaymentRequest(
                        paymentRequest,
                        success: { encryptedRequest in
                            XCTAssertNotNil(
                                encryptedRequest.encryptedCustomerInput,
                                "Encrypted customer input should not be null"
                            )
                            XCTAssertFalse(
                                encryptedRequest.encryptedCustomerInput.isEmpty,
                                "Encrypted customer input should not be empty"
                            )
                            encryptExpectation.fulfill()
                        },
                        failure: { error in
                            XCTFail("Should not fail: \(error)")
                            encryptExpectation.fulfill()
                        }
                    )
                } catch {
                    XCTFail("Should not fail setting values: \(error)")
                    encryptExpectation.fulfill()
                }
            },
            failure: { error in
                XCTFail("Should not fail getting product: \(error)")
                getProductExpectation.fulfill()
                encryptExpectation.fulfill()
            }
        )

        waitForExpectations(timeout: 15.0)
    }

    func testEncryptPaymentRequest_withMissingMandatoryField_shouldThrowException() {
        let getProductExpectation = expectation(description: "Get payment product")
        let encryptExpectation = expectation(description: "Encrypt payment request")

        // Get a payment product
        let productId = 1  // VISA
        sdk.paymentProduct(
            withId: productId,
            paymentContext: paymentContext,
            success: { paymentProduct in
                getProductExpectation.fulfill()

                // Create payment request without mandatory field (cardNumber)
                let paymentRequest = PaymentRequest(paymentProduct: paymentProduct)
                do {
                    try paymentRequest.setValue(id: "cardholderName", value: "Test Cardholder")
                    try paymentRequest.setValue(id: "cvv", value: "123")
                    try paymentRequest.setValue(id: "expiryDate", value: "1230")
                    // Missing cardNumber

                    // Encrypt the request
                    self.sdk.encryptPaymentRequest(
                        paymentRequest,
                        success: { _ in
                            XCTFail("Should have thrown an exception for missing mandatory field")
                            encryptExpectation.fulfill()
                        },
                        failure: { error in
                            // Expected
                            if let invalidError = error as? InvalidArgumentError {
                                XCTAssertEqual("The payment request is not valid.", invalidError.message)
                            }

                            encryptExpectation.fulfill()
                        }
                    )
                } catch {
                    XCTFail("Should not fail setting values: \(error)")
                    encryptExpectation.fulfill()
                }
            },
            failure: { error in
                XCTFail("Should not fail getting product: \(error)")
                getProductExpectation.fulfill()
                encryptExpectation.fulfill()
            }
        )

        waitForExpectations(timeout: 15.0)
    }

    func testEncryptPaymentRequest_withInvalidCardNumber_shouldThrowException() {
        let getProductExpectation = expectation(description: "Get payment product")
        let encryptExpectation = expectation(description: "Encrypt payment request")

        // Get a payment product
        let productId = 1  // VISA
        sdk.paymentProduct(
            withId: productId,
            paymentContext: paymentContext,
            success: { paymentProduct in
                getProductExpectation.fulfill()

                // Create payment request with invalid card number (fails Luhn check)
                let paymentRequest = PaymentRequest(paymentProduct: paymentProduct)
                do {
                    try paymentRequest.setValue(id: "cardNumber", value: "4222422242224222")
                    try paymentRequest.setValue(id: "cardholderName", value: "Test Cardholder")
                    try paymentRequest.setValue(id: "cvv", value: "123")
                    try paymentRequest.setValue(id: "expiryDate", value: "1230")

                    // Encrypt the request
                    self.sdk.encryptPaymentRequest(
                        paymentRequest,
                        success: { _ in
                            XCTFail("Should have thrown an exception for invalid card number")
                            encryptExpectation.fulfill()
                        },
                        failure: { error in
                            // Expected - should fail Luhn validation
                            XCTAssertNotNil(error)
                            if let invalidError = error as? InvalidArgumentError {
                                XCTAssertEqual("The payment request is not valid.", invalidError.message)
                            }

                            encryptExpectation.fulfill()
                        }
                    )
                } catch {
                    XCTFail("Should not fail setting values: \(error)")
                    encryptExpectation.fulfill()
                }
            },
            failure: { error in
                XCTFail("Should not fail getting product: \(error)")
                getProductExpectation.fulfill()
                encryptExpectation.fulfill()
            }
        )

        waitForExpectations(timeout: 15.0)
    }

    func testEncryptPaymentRequest_validation_shouldCheckAllFields() {
        let getProductExpectation = expectation(description: "Get payment product")
        let validateExpectation = expectation(description: "Validate payment request")

        // Get a payment product
        let productId = 1  // VISA
        sdk.paymentProduct(
            withId: productId,
            paymentContext: paymentContext,
            success: { paymentProduct in
                getProductExpectation.fulfill()

                // Create payment request
                let paymentRequest = PaymentRequest(paymentProduct: paymentProduct)
                do {
                    try paymentRequest.setValue(id: "cardNumber", value: "4567350000427977")
                    try paymentRequest.setValue(id: "cardholderName", value: "Test Cardholder")
                    try paymentRequest.setValue(id: "cvv", value: "123")
                    try paymentRequest.setValue(id: "expiryDate", value: "1230")

                    // Validate the request
                    let validationResult = try paymentRequest.validate()

                    XCTAssertTrue(validationResult.isValid, "Payment request should be valid")
                    XCTAssertTrue(validationResult.errors.isEmpty, "Should have no validation errors")

                    validateExpectation.fulfill()
                } catch {
                    XCTFail("Should not fail setting values: \(error)")
                    validateExpectation.fulfill()
                }
            },
            failure: { error in
                XCTFail("Should not fail getting product: \(error)")
                getProductExpectation.fulfill()
                validateExpectation.fulfill()
            }
        )

        waitForExpectations(timeout: 15.0)
    }

    func testEncryptPaymentRequest_multipleRequests_shouldGenerateDifferentEncryptedData() {
        let getProductExpectation = expectation(description: "Get payment product")
        let encryptExpectation1 = expectation(description: "Encrypt first request")
        let encryptExpectation2 = expectation(description: "Encrypt second request")

        var encryptedResult1: String?
        var encryptedResult2: String?

        // Get a payment product
        let productId = 1  // VISA
        sdk.paymentProduct(
            withId: productId,
            paymentContext: paymentContext,
            success: { paymentProduct in
                getProductExpectation.fulfill()

                // Create first payment request
                let paymentRequest1 = PaymentRequest(paymentProduct: paymentProduct)
                do {
                    try paymentRequest1.setValue(id: "cardNumber", value: "4567350000427977")
                    try paymentRequest1.setValue(id: "cardholderName", value: "Test Cardholder 1")
                    try paymentRequest1.setValue(id: "cvv", value: "123")
                    try paymentRequest1.setValue(id: "expiryDate", value: "1230")

                    // Encrypt first request
                    self.sdk.encryptPaymentRequest(
                        paymentRequest1,
                        success: { result1 in
                            encryptedResult1 = result1.encryptedCustomerInput
                            encryptExpectation1.fulfill()

                            // Create second payment request with same data
                            let paymentRequest2 = PaymentRequest(paymentProduct: paymentProduct)
                            do {
                                try paymentRequest2.setValue(id: "cardNumber", value: "4567350000427977")
                                try paymentRequest2.setValue(id: "cardholderName", value: "Test Cardholder 1")
                                try paymentRequest2.setValue(id: "cvv", value: "123")
                                try paymentRequest2.setValue(id: "expiryDate", value: "1230")

                                // Encrypt second request
                                self.sdk.encryptPaymentRequest(
                                    paymentRequest2,
                                    success: { result2 in
                                        encryptedResult2 = result2.encryptedCustomerInput

                                        // Results should be different due to random nonce in encryption
                        
                                        // The encrypted outputs should be different even with same input
                                        XCTAssertTrue(
                                            encryptedResult1 != encryptedResult2,
                                            "Encrypted data should be different even with same input (random nonce)"
                                        )

                                        encryptExpectation2.fulfill()
                                    },
                                    failure: { error in
                                        XCTFail("Second encryption should not fail: \(error)")
                                        encryptExpectation2.fulfill()
                                    }
                                )
                            } catch {
                                XCTFail("Should not fail setting values: \(error)")
                                encryptExpectation2.fulfill()
                            }
                        },
                        failure: { error in
                            XCTFail("First encryption should not fail: \(error)")
                            encryptExpectation1.fulfill()
                            encryptExpectation2.fulfill()
                        }
                    )
                } catch {
                    XCTFail("Should not fail setting values: \(error)")
                    encryptExpectation1.fulfill()
                    encryptExpectation2.fulfill()
                }
            },
            failure: { error in
                XCTFail("Should not fail getting product: \(error)")
                getProductExpectation.fulfill()
                encryptExpectation1.fulfill()
                encryptExpectation2.fulfill()
            }
        )

        waitForExpectations(timeout: 20.0)
    }

    func testCreateToken_withValidData_shouldSucceed() {
        let requestExpectation = expectation(description: "Create valid request")
        let tokenExpectation = expectation(description: "Create token")

        createValidRequest { paymentRequest in
            requestExpectation.fulfill()

            self.sdk.encryptPaymentRequest(
                paymentRequest,
                success: { encryptedRequest in

                    // Use ServerApiUtility to create token
                    let tokenRequest = CreateTokenRequest(
                        encryptedCustomerInput: encryptedRequest.encryptedCustomerInput
                    )

                    self.serverApi.createToken(request: tokenRequest) { result in
                        switch result {
                        case .success(let response):
                            XCTAssertNotNil(response.token)
                            XCTAssertNotNil(response.isNewToken)
                        case .failure(let error):
                            XCTFail("Token creation should succeed: \(error)")
                        }

                        tokenExpectation.fulfill()
                    }
                },
                failure: { error in
                    XCTFail("Encryption should succeed: \(error)")
                    tokenExpectation.fulfill()
                }

            )
        }

        waitForExpectations(timeout: 20.0)
    }

    func testCreatePayment_withValidData_shouldSucceed() {
        let requestExpectation = expectation(description: "Create valid request")
        let paymentExpectation = expectation(description: "Create payment")

        createValidRequest { paymentRequest in
            requestExpectation.fulfill()

            self.sdk.encryptPaymentRequest(
                paymentRequest,
                success: { encryptedRequest in

                    // Create payment request
                    let paymentOrder = PaymentOrder(
                        amountOfMoney: PaymentAmountOfMoney(amount: 1000, currencyCode: "EUR"),
                        customer: PaymentCustomer(
                            billingAddress: PaymentAddress(
                                countryCode: "NL",
                                city: "Amsterdam",
                                street: "Test Street 123",
                                zip: "1012AB"
                            ),
                            merchantCustomerId: "test-customer-123"
                        )
                    )

                    let paymentRequest = CreatePaymentRequest(
                        order: paymentOrder,
                        encryptedCustomerInput: encryptedRequest.encryptedCustomerInput
                    )

                    self.serverApi.createPayment(request: paymentRequest) { result in
                        switch result {
                        case .success(let response):
                            XCTAssertNotNil(response.payment)
                            XCTAssertNotNil(response.payment?.id)
                        case .failure(let error):
                            XCTFail("Payment creation should succeed: \(error)")
                        }

                        paymentExpectation.fulfill()
                    }
                },
                failure: { error in
                    XCTFail("Encryption should succeed: \(error)")
                    paymentExpectation.fulfill()
                }
            )
        }

        waitForExpectations(timeout: 20.0)
    }

    func testEncryptPaymentRequest_ValidRequest_ReturnsEncodedClientMetaInfo() {
        let getProductExpectation = expectation(description: "Get payment product")
        let encryptExpectation = expectation(description: "Encrypt payment request")

        sdk.paymentProduct(
            withId: 1,
            paymentContext: paymentContext,
            success: { paymentProduct in
                getProductExpectation.fulfill()

                let paymentRequest = PaymentRequest(paymentProduct: paymentProduct)
                do {
                    try paymentRequest.setValue(id: "cardNumber", value: "4567350000427977")
                    try paymentRequest.setValue(id: "cardholderName", value: "Test Cardholder")
                    try paymentRequest.setValue(id: "cvv", value: "123")
                    try paymentRequest.setValue(id: "expiryDate", value: "1230")

                    self.sdk.encryptPaymentRequest(
                        paymentRequest,
                        success: { encryptedRequest in
                            XCTAssertFalse(
                                encryptedRequest.encryptedCustomerInput.isEmpty,
                                "Encrypted customer input should not be empty"
                            )

                            XCTAssertFalse(
                                encryptedRequest.encodedClientMetaInfo.isEmpty,
                                "encodedClientMetaInfo should not be empty"
                            )

                            encryptExpectation.fulfill()
                        },
                        failure: { error in
                            XCTFail("Should not fail: \(error)")
                            encryptExpectation.fulfill()
                        }
                    )
                } catch {
                    XCTFail("Should not fail setting values: \(error)")
                    encryptExpectation.fulfill()
                }
            },
            failure: { error in
                XCTFail("Should not fail getting product: \(error)")
                getProductExpectation.fulfill()
                encryptExpectation.fulfill()
            }
        )

        waitForExpectations(timeout: 15.0)
    }

    func testEncryptPaymentRequest_MissingMandatoryField_DoesNotCallPublicKeyApi() {
        var publicKeyApiCalled = false
        stub(condition: isMethodGET() && { req in
            req.url?.path.hasSuffix("/crypto/publickey") == true
        }) { _ in
            publicKeyApiCalled = true

            return HTTPStubsResponse(
                error: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
            )
        }

        defer { HTTPStubs.removeAllStubs() }

        let getProductExpectation = expectation(description: "Get payment product")
        let encryptExpectation = expectation(description: "Encrypt payment request")

        sdk.paymentProduct(
            withId: 1,
            paymentContext: paymentContext,
            success: { paymentProduct in
                getProductExpectation.fulfill()

                let paymentRequest = PaymentRequest(paymentProduct: paymentProduct)
                do {
                    try paymentRequest.setValue(id: "cardholderName", value: "Test Cardholder")
                    try paymentRequest.setValue(id: "cvv", value: "123")
                    try paymentRequest.setValue(id: "expiryDate", value: "1230")
                    // Missing cardNumber — validation should fail before public key is fetched

                    self.sdk.encryptPaymentRequest(
                        paymentRequest,
                        success: { _ in
                            XCTFail("Should have failed for missing mandatory field")
                            encryptExpectation.fulfill()
                        },
                        failure: { error in
                            XCTAssertTrue(
                                error is InvalidArgumentError,
                                "Expected InvalidArgumentError when mandatory field is missing, got: \(type(of: error))"
                         )

                            XCTAssertFalse(
                                publicKeyApiCalled,
                                "Public key API should not be called when validation fails"
                         )

                            encryptExpectation.fulfill()
                        }
                    )
                } catch {
                    XCTFail("Should not fail setting values: \(error)")
                    encryptExpectation.fulfill()
                }
            },
            failure: { error in
                XCTFail("Should not fail getting product: \(error)")
                getProductExpectation.fulfill()
                encryptExpectation.fulfill()
            }
        )

        waitForExpectations(timeout: 15.0)
    }

    func testEncryptPaymentRequest_WithAofReadOnlyField_ThrowsOnSetValue() {
        let setupExpectation = expectation(description: "Setup AoF")

        createSdkWithAccountOnFile { _, productWithAof in
            setupExpectation.fulfill()

            guard let aof = productWithAof.accountsOnFile.first else {
                XCTFail("Payment product should have at least one account on file")

                return
            }

            let readOnlyFieldId = aof.getReadOnlyAttributes()
                .map { $0.key }
                .first { productWithAof.field(id: $0) != nil }

            guard let fieldId = readOnlyFieldId else {
                // No READ_ONLY filed found that also exists as a product in field in this integration environment.

                return
            }

            let paymentRequest = PaymentRequest(paymentProduct: productWithAof, accountOnFile: aof)

            do {
                try paymentRequest.setValue(id: fieldId, value: "test-value")
                XCTFail("Should have thrown for READ_ONLY field: \(fieldId)")
            } catch let error as SdkError {
                XCTAssertTrue(
                    error.message.contains("Cannot write"),
                    "Error should mention that the field cannot be written, got: \(error.message)"
                )

                XCTAssertTrue(
                    error.message.contains(fieldId),
                    "Error should mention fieldId \(fieldId), got: \(error.message)"
                )
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }

        waitForExpectations(timeout: 30.0)
    }

    func testEncryptPaymentRequest_WithAof_ValidationFailsForShortCvv() {
        let setupExpectation = expectation(description: "Setup AoF")
        let encryptExpectation = expectation(description: "Encrypt with short CVV")

        createSdkWithAccountOnFile { aofSdk, productWithAof in
            setupExpectation.fulfill()

            guard let aof = productWithAof.accountsOnFile.first else {
                XCTFail("Payment product should have at least one account on file")
                encryptExpectation.fulfill()

                return
            }

            let paymentRequest = PaymentRequest(paymentProduct: productWithAof, accountOnFile: aof)
            do {
                try paymentRequest.setValue(id: "cvv", value: "1")  // Too short — min is 3
            } catch {
                XCTFail("setValue should not throw: \(error)")
                encryptExpectation.fulfill()

                return
            }

            aofSdk.encryptPaymentRequest(
                paymentRequest,
                success: { _ in
                    XCTFail("Should have failed validation for short CVV")
                    encryptExpectation.fulfill()
                },
                failure: { error in
                    XCTAssertTrue(
                        error is InvalidArgumentError,
                        "Expected InvalidArgumentError for short CVV, got: \(type(of: error))"
                 )

                    encryptExpectation.fulfill()
                }

            )
        }

        waitForExpectations(timeout: 30.0)
    }

    func testEncryptPaymentRequest_WithAofEndToEnd_CreatesPaymentSuccessfully() {
        let setupExpectation = expectation(description: "Setup AoF")
        let encryptExpectation = expectation(description: "Encrypt with AoF")
        let paymentExpectation = expectation(description: "Create payment")

        createSdkWithAccountOnFile { aofSdk, productWithAof in
            setupExpectation.fulfill()

            guard let aof = productWithAof.accountsOnFile.first else {
                XCTFail("Payment product should have at least one account on file")
                encryptExpectation.fulfill()
                paymentExpectation.fulfill()

                return
            }

            let paymentRequest = PaymentRequest(paymentProduct: productWithAof, accountOnFile: aof)
            do {
                try paymentRequest.setValue(id: "cvv", value: "123")
            } catch {
                XCTFail("setValue should not throw: \(error)")
                encryptExpectation.fulfill()
                paymentExpectation.fulfill()

                return
            }

            aofSdk.encryptPaymentRequest(
                paymentRequest,
                success: { encryptedRequest in
                    XCTAssertFalse(
                        encryptedRequest.encryptedCustomerInput.isEmpty,
                        "Encrypted customer input should not be empty"
                 )

                    XCTAssertFalse(
                        encryptedRequest.encodedClientMetaInfo.isEmpty,
                        "Encoded client meta info should not be empty"
                 )

                    encryptExpectation.fulfill()

                    let paymentOrder = CreatePaymentRequest(
                        order: PaymentOrder(
                            amountOfMoney: PaymentAmountOfMoney(amount: 1000, currencyCode: "EUR"),
                            customer: PaymentCustomer(
                                billingAddress: PaymentAddress(
                                    countryCode: "NL",
                                    city: "Amsterdam",
                                    street: "Test Street 123",
                                    zip: "1012AB"
                                ),
                                merchantCustomerId: "test-customer-aof"
                            )
                        ),
                        encryptedCustomerInput: encryptedRequest.encryptedCustomerInput
                    )

                    self.serverApi.createPayment(request: paymentOrder) { result in
                        switch result {
                        case .success(let response):
                            XCTAssertNotNil(response.payment, "Payment should be returned")
                            XCTAssertFalse(
                                response.payment?.id?.isEmpty ?? true,
                                "Payment ID should not be empty"
                         )
                            
                        case .failure(let error):
                            XCTFail("Payment creation should succeed: \(error)")
                        }

                        paymentExpectation.fulfill()
                    }
                },
                failure: { error in
                    XCTFail("Encryption should succeed: \(error)")
                    encryptExpectation.fulfill()
                    paymentExpectation.fulfill()
                }

            )
        }

        waitForExpectations(timeout: 45.0)
    }

    func testEncryptPaymentRequest_WithTokenizeFlag_EncryptsSuccessfully() {
        let getProductExpectation = expectation(description: "Get payment product")
        let encryptExpectation = expectation(description: "Encrypt payment request with tokenize")

        sdk.paymentProduct(
            withId: 1,
            paymentContext: paymentContext,
            success: { paymentProduct in
                getProductExpectation.fulfill()

                let paymentRequest = PaymentRequest(paymentProduct: paymentProduct, tokenize: true)
                do {
                    try paymentRequest.setValue(id: "cardNumber", value: "4567350000427977")
                    try paymentRequest.setValue(id: "cardholderName", value: "Test Cardholder")
                    try paymentRequest.setValue(id: "cvv", value: "123")
                    try paymentRequest.setValue(id: "expiryDate", value: "1230")

                    XCTAssertTrue(paymentRequest.tokenize, "Tokenize flag should be set to true")

                    self.sdk.encryptPaymentRequest(
                        paymentRequest,
                        success: { encryptedRequest in
                            XCTAssertTrue(
                                paymentRequest.tokenize,
                                "Tokenize flag should remain true after encryption"
                         )

                            XCTAssertFalse(
                                encryptedRequest.encryptedCustomerInput.isEmpty,
                                "Encrypted customer input should not be empty"
                         )

                            XCTAssertFalse(
                                encryptedRequest.encodedClientMetaInfo.isEmpty,
                                "Encoded client meta info should not be empty"
                         )

                            encryptExpectation.fulfill()
                        },
                        failure: { error in
                            XCTFail("Should not fail when tokenize is set: \(error)")
                            encryptExpectation.fulfill()
                        }

                    )
                } catch {
                    XCTFail("Should not fail setting values: \(error)")
                    encryptExpectation.fulfill()
                }
            },
            failure: { error in
                XCTFail("Should not fail getting product: \(error)")
                getProductExpectation.fulfill()
                encryptExpectation.fulfill()
            }

        )

        waitForExpectations(timeout: 15.0)
    }

    // MARK: - Helper Methods

    /// Creates a new SDK instance initialised with a session that contains a token (account on file).
    /// Calls `completion` with the new SDK and the payment product (product id 1) which will
    /// contain one `AccountOnFile` entry backed by the created token.
    private func createSdkWithAccountOnFile(
        completion: @escaping (OnlinePaymentsSdk, PaymentProduct) -> Void
    ) {
        let tokenRequest = CreditCardTokenRequest()
        tokenRequest.cardNumber = "4567350000427977"
        tokenRequest.cardholderName = "Test Cardholder"
        tokenRequest.expiryDate = "1230"
        tokenRequest.securityCode = "123"
        tokenRequest.paymentProductId = NSNumber(value: 1)

        sdk.encryptTokenRequest(
            tokenRequest,
            success: { encrypted in
                let createTokenReq = CreateTokenRequest(
                    encryptedCustomerInput: encrypted.encryptedCustomerInput
                )
                self.serverApi.createToken(request: createTokenReq) { tokenResult in
                    switch tokenResult {
                    case .success(let tokenResponse):
                        guard let token = tokenResponse.token else {
                            XCTFail("Token should not be nil")

                            return
                        }

                        let sessionReq = CreateSessionRequest(tokens: [token])
                        self.serverApi.createSession(request: sessionReq) { sessionResult in
                            switch sessionResult {
                            case .success(let sessionResponse):
                                guard
                                    let clientSessionId = sessionResponse.clientSessionId,
                                    let customerId = sessionResponse.customerId,
                                    let clientApiUrl = sessionResponse.clientApiUrl,
                                    let assetUrl = sessionResponse.assetUrl
                                else {
                                    XCTFail("Invalid session response")

                                    return
                                }

                                let sessionData = SessionData(
                                    clientSessionId: clientSessionId,
                                    customerId: customerId,
                                    clientApiUrl: clientApiUrl,
                                    assetUrl: assetUrl
                                )
                                let aofSdk = try! OnlinePaymentsSdk(
                                    sessionData: sessionData,
                                    configuration: SdkConfiguration(
                                        appIdentifier: "SwiftSDK/IntegrationTests"
                                    )
                                )

                                aofSdk.paymentProduct(
                                    withId: 1,
                                    paymentContext: self.paymentContext,
                                    success: { product in
                                        completion(aofSdk, product)
                                    },
                                    failure: { error in
                                        XCTFail("Failed to fetch product with AoF: \(error)")
                                    }
                                )

                            case .failure(let error):
                                XCTFail("Failed to create session with token: \(error)")
                            }
                        }

                    case .failure(let error):
                        XCTFail("Failed to create token: \(error)")
                    }
                }
            },
            failure: { error in
                XCTFail("Failed to encrypt token request: \(error)")
            }

        )
    }

    private func createValidRequest(completion: @escaping (PaymentRequest) -> Void) {        let productId = 1  // VISA

        sdk.paymentProduct(
            withId: productId,
            paymentContext: paymentContext,
            success: { paymentProduct in
                let paymentRequest = PaymentRequest(paymentProduct: paymentProduct)
                do {
                    try paymentRequest.setValue(id: "cardNumber", value: TestData.visaCardNumber)
                    try paymentRequest.setValue(id: "cardholderName", value: "Test Cardholder")
                    try paymentRequest.setValue(id: "cvv", value: TestData.cvv)

                    // Determine the correct expiry date format (4 or 6 digits)
                    if let expiryField = paymentProduct.field(id: "expiryDate") {
                        let maskedValue = expiryField.applyMask(value: "122030")
                        let validValue = (maskedValue?.count == 5) ? TestData.expiryDateMMYY : "122030"
                        try paymentRequest.setValue(id: "expiryDate", value: validValue)
                    } else {
                        try paymentRequest.setValue(id: "expiryDate", value: TestData.expiryDateMMYY)
                    }

                    completion(paymentRequest)
                } catch {
                    XCTFail("Should not fail setting values: \(error)")
                }
            },
            failure: { error in
                XCTFail("Should not fail getting product: \(error)")
            }

        )
    }
}
