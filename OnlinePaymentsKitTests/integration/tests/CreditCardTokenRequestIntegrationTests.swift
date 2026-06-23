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

/// Integration tests for credit card tokenization request encryption.
/// Tests real encryption with actual public keys from the preprod environment.
class CreditCardTokenRequestIntegrationTests: BaseIntegrationTest {

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

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
                    case .failure:
                        break
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

    func testEncryptTokenRequest_MissingPaymentProductId_ThrowsEncryptionError() {
        let expectation = expectation(description: "Encrypt token request with missing paymentProductId")

        let tokenRequest = CreditCardTokenRequest()
        tokenRequest.cardNumber = "4242424242424242"
        tokenRequest.cardholderName = "Test Cardholder"
        tokenRequest.securityCode = "123"
        tokenRequest.expiryDate = "1230"

        sdk.encryptTokenRequest(
            tokenRequest,
            success: { _ in
                XCTFail("Should have failed when paymentProductId is not set")
                expectation.fulfill()
            },
            failure: { error in
                let encryptionError = error as? EncryptionError

                XCTAssertNotNil(encryptionError, "Error should be an EncryptionError")
                XCTAssertTrue(
                    error.message.contains("payment product ID not set"),
                    "Error message should mention missing payment product ID, got: \(error.message)"
                )

                expectation.fulfill()
            }

        )

        waitForExpectations(timeout: 10.0)
    }

    func testEncryptTokenRequest_returnsCorrectValuesMap() {
        let tokenRequest = CreditCardTokenRequest()
        tokenRequest.paymentProductId = NSNumber(value: 1)
        tokenRequest.cardNumber = TestData.visaCardNumber
        tokenRequest.cardholderName = "Test Cardholder"
        tokenRequest.securityCode = TestData.cvv
        tokenRequest.expiryDate = TestData.expiryDateMMYY

        let values = tokenRequest.getValues()

        XCTAssertEqual(TestData.visaCardNumber, values["cardNumber"])
        XCTAssertEqual("Test Cardholder", values["cardholderName"])
        XCTAssertEqual(TestData.expiryDateMMYY, values["expiryDate"])
        XCTAssertEqual(TestData.cvv, values["cvv"])
    }

    func testEncryptTokenRequest_ValidRequest_ReturnsEncodedClientMetaInfo() {
        let expectation = expectation(description: "Encrypt token request — encodedClientMetaInfo")

        getValidRequest { tokenRequest in
            self.sdk.encryptTokenRequest(
                tokenRequest,
                success: { encryptedRequest in
                    XCTAssertNotNil(
                        encryptedRequest.encodedClientMetaInfo,
                        "encodedClientMetaInfo should not be null"
                    )
                    XCTAssertFalse(
                        encryptedRequest.encodedClientMetaInfo.isEmpty,
                        "encodedClientMetaInfo should not be empty"
                    )
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

    func testEncryptTokenRequest_returnsEncryptedTokenAsString() {
        let expectation = expectation(description: "Encrypt token request — encryptedCustomerInput")

        getValidRequest { tokenRequest in
          self.sdk.encryptTokenRequest(
            tokenRequest,
            success: { encryptedRequest in
              XCTAssertFalse(
                encryptedRequest.encryptedCustomerInput.isEmpty,
                "encryptedCustomerInput should not be empty"
              )

              XCTAssertEqual(
                5,
                encryptedRequest.encryptedCustomerInput.split(separator: ".").count,
                "encryptedCustomerInput should be a JWE compact serialization"
              )

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

    // MARK: - Helper Methods

    private func assertAllValid(_ result: EncryptedRequest) {
        XCTAssertFalse(
            result.encryptedCustomerInput.isEmpty,
            "Encrypted customer input should not be empty"
        )

        XCTAssertFalse(
            result.encodedClientMetaInfo.isEmpty,
            "Encoded client meta info should not be empty"
        )

        XCTAssertEqual(
            5,
            result.encryptedCustomerInput.split(separator: ".").count,
            "Encrypted customer input should be a JWE compact serialization"
        )
    }

    private func getValidRequest(completion: @escaping (CreditCardTokenRequest) -> Void) {
        sdk.paymentProduct(
            withId: 1,
            paymentContext: paymentContext,
            success: { paymentProduct in
                let request = CreditCardTokenRequest()
                request.paymentProductId = NSNumber(value: 1)
                request.cardNumber = TestData.visaCardNumber
                request.cardholderName = "Test Cardholder"
                request.securityCode = TestData.cvv

                // Determine the correct expiry date format (4 or 6 digits)
                if let expiryField = paymentProduct.field(id: "expiryDate") {
                    let maskedValue = expiryField.applyMask(value: "122030")
                    let validValue = (maskedValue?.count == 5) ? TestData.expiryDateMMYY : "122030"
                    request.expiryDate = validValue
                } else {
                    request.expiryDate = TestData.expiryDateMMYY
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
