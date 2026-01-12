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

/// Integration tests for payment request encryption.
/// Tests real encryption with actual public keys from the preprod environment.
class PaymentRequestIntegrationTests: BaseIntegrationTest {

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
                    try paymentRequest.setValue(id: "expiryDate", value: "1226")

                    // Encrypt the request
                    self.sdk.encryptPaymentRequest(
                        paymentRequest,
                        success: { encryptedRequest in
                            XCTAssertNotNil(encryptedRequest, "Result should not be null")
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
                    try paymentRequest.setValue(id: "expiryDate", value: "1226")
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
                    try paymentRequest.setValue(id: "expiryDate", value: "1226")

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
                    try paymentRequest.setValue(id: "expiryDate", value: "1226")

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
                    try paymentRequest1.setValue(id: "expiryDate", value: "1226")

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
                                try paymentRequest2.setValue(id: "expiryDate", value: "1226")

                                // Encrypt second request
                                self.sdk.encryptPaymentRequest(
                                    paymentRequest2,
                                    success: { result2 in
                                        encryptedResult2 = result2.encryptedCustomerInput

                                        // Results should be different due to random nonce in encryption
                                        XCTAssertNotNil(encryptedResult1, "First result should not be null")
                                        XCTAssertNotNil(encryptedResult2, "Second result should not be null")

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
                    XCTAssertNotNil(encryptedRequest, "Encryption should succeed")

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
                    XCTAssertNotNil(encryptedRequest, "Encryption should succeed")

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

    // MARK: - Helper Methods

    private func createValidRequest(completion: @escaping (PaymentRequest) -> Void) {
        let productId = 1  // VISA

        sdk.paymentProduct(
            withId: productId,
            paymentContext: paymentContext,
            success: { paymentProduct in
                let paymentRequest = PaymentRequest(paymentProduct: paymentProduct)
                do {
                    try paymentRequest.setValue(id: "cardNumber", value: "4242424242424242")
                    try paymentRequest.setValue(id: "cardholderName", value: "Test Cardholder")
                    try paymentRequest.setValue(id: "cvv", value: "123")

                    // Determine the correct expiry date format (4 or 6 digits)
                    if let expiryField = paymentProduct.field(id: "expiryDate") {
                        let maskedValue = expiryField.applyMask(value: "122030")
                        let validValue = (maskedValue?.count == 5) ? "1230" : "122030"
                        try paymentRequest.setValue(id: "expiryDate", value: validValue)
                    } else {
                        try paymentRequest.setValue(id: "expiryDate", value: "1230")
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
