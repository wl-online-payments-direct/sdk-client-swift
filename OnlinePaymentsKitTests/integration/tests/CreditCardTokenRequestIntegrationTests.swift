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

/// Integration tests for credit card tokenization request encryption.
/// Tests real encryption with actual public keys from the preprod environment.
class CreditCardTokenRequestIntegrationTests: BaseIntegrationTest {

    func testEncryptTokenRequest_withValidData_shouldReturnEncryptedData() {
        let expectation = expectation(description: "Encrypt token request")
        getValidRequest { tokenRequest in
            self.sdk.encryptTokenRequest(
                tokenRequest,
                success: { encryptedRequest in
                    self.assertAllValid(encryptedRequest)
                    expectation.fulfill()
                },
                failure: { error in
                    XCTFail("Should not fail: \(error)")
                    expectation.fulfill()
                }
            )
        }

        waitForExpectations(timeout: 10.0)
    }

    func testEncryptTokenRequest_withInvalidData_shouldReturnEncryptedData() {
        let expectation = expectation(description: "Encrypt token request with invalid data")

        sdk.encryptTokenRequest(
            getInvalidRequest(),
            success: { encryptedRequest in
                self.assertAllValid(encryptedRequest)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testCreateToken_withValidData_shouldSucceed() {
        let encryptExpectation = expectation(description: "Encrypt token request")
        let tokenExpectation = expectation(description: "Create token")

        getValidRequest { tokenRequest in
            self.sdk.encryptTokenRequest(
                tokenRequest,
                success: { encryptedRequest in
                    encryptExpectation.fulfill()

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
                    XCTFail("Encryption should not fail: \(error)")
                    encryptExpectation.fulfill()
                    tokenExpectation.fulfill()
                }
            )
        }

        waitForExpectations(timeout: 15.0)
    }

    func testCreateToken_withInvalidData_shouldFail() {
        let encryptExpectation = expectation(description: "Encrypt token request")
        let tokenExpectation = expectation(description: "Create token")

        sdk.encryptTokenRequest(
            getInvalidRequest(),
            success: { encryptedRequest in
                encryptExpectation.fulfill()

                // Create token request with invalid data (missing CVV and expiryDate)
                let tokenRequest = CreateTokenRequest(
                    encryptedCustomerInput: encryptedRequest.encryptedCustomerInput
                )

                self.serverApi.createToken(request: tokenRequest) { result in
                    switch result {
                    case .success:
                        XCTFail("Should not create token with invalid data")
                    case .failure(let error):
                        XCTAssertNotNil(error)
                    }
                    tokenExpectation.fulfill()
                }
            },
            failure: { error in
                XCTFail("Encryption should not fail: \(error)")
                encryptExpectation.fulfill()
                tokenExpectation.fulfill()
            }
        )

        waitForExpectations(timeout: 15.0)
    }

    // MARK: - Helper Methods

    private func assertAllValid(_ result: EncryptedRequest) {
        XCTAssertNotNil(result, "Result should not be null")
        XCTAssertNotNil(result.encryptedCustomerInput, "Encrypted customer input should not be null")
        XCTAssertFalse(
            result.encryptedCustomerInput.isEmpty,
            "Encrypted customer input should not be empty"
        )
    }

    private func getValidRequest(completion: @escaping (CreditCardTokenRequest) -> Void) {
        sdk.paymentProduct(
            withId: 1,
            paymentContext: paymentContext,
            success: { paymentProduct in
                let request = CreditCardTokenRequest()
                request.paymentProductId = 1  // VISA
                request.cardNumber = "4242424242424242"
                request.cardholderName = "Test Cardholder"
                request.securityCode = "123"

                // Determine the correct expiry date format (4 or 6 digits)
                if let expiryField = paymentProduct.field(id: "expiryDate") {
                    let maskedValue = expiryField.applyMask(value: "122030")
                    let validValue = (maskedValue?.count == 5) ? "1230" : "122030"
                    request.expiryDate = validValue
                } else {
                    request.expiryDate = "1230"
                }

                completion(request)
            },
            failure: { error in
                XCTFail("Should not fail getting product: \(error)")
            }
        )
    }

    private func getInvalidRequest() -> CreditCardTokenRequest {
        let request = CreditCardTokenRequest()
        request.paymentProductId = NSNumber(value: 1)  // VISA
        request.cardNumber = "4567350000427977"
        request.cardholderName = "Test Cardholder"
        // Missing CVV and expiryDate

        return request
    }
}
