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
class PaymentRequestIntegrationTests: BaseIntegrationTest {

  private let visaProductId = 1

  override func tearDown() {
    HTTPStubs.removeAllStubs()
    super.tearDown()
  }

  func testApplyMask_producesCorrectlyFormattedOutput() {
    let expectation = expectation(description: "Apply mask")

    sdk.paymentProduct(
      withId: visaProductId,
      paymentContext: paymentContext,
      success: { paymentProduct in
        guard let cardNumberField = paymentProduct.field(id: "cardNumber") else {
          XCTFail("Payment product should contain cardNumber field")
          expectation.fulfill()
          return
        }

        let maskedValue = cardNumberField.applyMask(value: "4242424242424242")
        let normalizedMaskedValue = maskedValue?.trimmingCharacters(in: .whitespaces)

        XCTAssertEqual(
          "4242 4242 4242 4242",
          normalizedMaskedValue,
          "Card number should be formatted according to the field mask"
        )

        expectation.fulfill()
      },
      failure: { error in
        XCTFail("Should not fail getting product: \(error)")
        expectation.fulfill()
      }
    )

    waitForExpectations(timeout: 10.0)
  }

  func testEncryptPaymentRequest_doesNotCallPublicKeyApiWhenMandatoryFieldIsMissing() {
    var publicKeyApiCalled = false

    stub(condition: isMethodGET() && { request in
      request.url?.path.hasSuffix("/crypto/publickey") == true
    }) { _ in
      publicKeyApiCalled = true

      return HTTPStubsResponse(
        error: NSError(
          domain: NSURLErrorDomain,
          code: NSURLErrorNotConnectedToInternet
        )
      )
    }

    let expectation = expectation(description: "Encrypt invalid payment request")

    sdk.paymentProduct(
      withId: visaProductId,
      paymentContext: paymentContext,
      success: { paymentProduct in
        let paymentRequest = PaymentRequest(paymentProduct: paymentProduct)

        do {
          try paymentRequest.setValue(id: "cardholderName", value: "Test Cardholder")
          try paymentRequest.setValue(id: "cvv", value: TestData.cvv)
          try paymentRequest.setValue(id: "expiryDate", value: TestData.expiryDateMMYY)

          self.sdk.encryptPaymentRequest(
            paymentRequest,
            success: { _ in
              XCTFail("Should fail when mandatory field is missing")
              expectation.fulfill()
            },
            failure: { error in
              XCTAssertTrue(
                error is InvalidArgumentError,
                "Expected InvalidArgumentError when mandatory field is missing"
              )

              XCTAssertFalse(
                publicKeyApiCalled,
                "Public key API should not be called when validation fails"
              )

              expectation.fulfill()
            }
          )
        } catch {
          XCTFail("Should not fail setting values: \(error)")
          expectation.fulfill()
        }
      },
      failure: { error in
        XCTFail("Should not fail getting product: \(error)")
        expectation.fulfill()
      }
    )

    waitForExpectations(timeout: 15.0)
  }

  func testEncryptPaymentRequest_encryptsValidPaymentRequest() {
    let expectation = expectation(description: "Encrypt valid payment request")

    createValidRequest { paymentRequest in
      self.sdk.encryptPaymentRequest(
        paymentRequest,
        success: { encryptedRequest in
          XCTAssertFalse(
            encryptedRequest.encryptedCustomerInput.isEmpty,
            "Encrypted customer input should not be empty"
          )

          XCTAssertEqual(
            5,
            encryptedRequest.encryptedCustomerInput.split(separator: ".").count,
            "Encrypted customer input should be a JWE compact serialization"
          )

          expectation.fulfill()
        },
        failure: { error in
          XCTFail("Encryption should succeed: \(error)")
          expectation.fulfill()
        }
      )
    }

    waitForExpectations(timeout: 15.0)
  }

  func testEncryptPaymentRequest_includesTokenizeFlagWhenTokenizeIsEnabled() {
    let expectation = expectation(description: "Encrypt payment request with tokenize")

    sdk.paymentProduct(
      withId: visaProductId,
      paymentContext: paymentContext,
      success: { paymentProduct in
        let paymentRequest = PaymentRequest(paymentProduct: paymentProduct, tokenize: true)

        do {
          try paymentRequest.setValue(id: "cardNumber", value: TestData.visaCardNumberAlt)
          try paymentRequest.setValue(id: "cardholderName", value: "Test Cardholder")
          try paymentRequest.setValue(id: "cvv", value: TestData.cvv)
          try paymentRequest.setValue(id: "expiryDate", value: TestData.expiryDateMMYY)

          XCTAssertTrue(paymentRequest.tokenize, "Tokenize flag should be enabled")

          self.sdk.encryptPaymentRequest(
            paymentRequest,
            success: { encryptedRequest in
              XCTAssertTrue(
                paymentRequest.tokenize,
                "Tokenize flag should remain enabled after encryption"
              )

              XCTAssertFalse(
                encryptedRequest.encryptedCustomerInput.isEmpty,
                "Encrypted customer input should not be empty"
              )

              expectation.fulfill()
            },
            failure: { error in
              XCTFail("Should not fail when tokenize is enabled: \(error)")
              expectation.fulfill()
            }
          )
        } catch {
          XCTFail("Should not fail setting values: \(error)")
          expectation.fulfill()
        }
      },
      failure: { error in
        XCTFail("Should not fail getting product: \(error)")
        expectation.fulfill()
      }
    )

    waitForExpectations(timeout: 15.0)
  }

  func testEncryptPaymentRequest_producesDifferentEncryptedOutputForMultipleRequests() {
    let firstExpectation = expectation(description: "Encrypt first request")
    let secondExpectation = expectation(description: "Encrypt second request")

    createValidRequest { firstPaymentRequest in
      self.sdk.encryptPaymentRequest(
        firstPaymentRequest,
        success: { firstEncryptedRequest in
          firstExpectation.fulfill()

          self.createValidRequest { secondPaymentRequest in
            self.sdk.encryptPaymentRequest(
              secondPaymentRequest,
              success: { secondEncryptedRequest in
                XCTAssertNotEqual(
                  firstEncryptedRequest.encryptedCustomerInput,
                  secondEncryptedRequest.encryptedCustomerInput,
                  "Encrypted output should be different because encryption uses random values"
                )

                secondExpectation.fulfill()
              },
              failure: { error in
                XCTFail("Second encryption should succeed: \(error)")
                secondExpectation.fulfill()
              }
            )
          }
        },
        failure: { error in
          XCTFail("First encryption should succeed: \(error)")
          firstExpectation.fulfill()
          secondExpectation.fulfill()
        }
      )
    }

    waitForExpectations(timeout: 25.0)
  }

  func testEncryptPaymentRequest_returnsEncodedClientMetaInformation() {
    let expectation = expectation(description: "Encrypt payment request")

    createValidRequest { paymentRequest in
      self.sdk.encryptPaymentRequest(
        paymentRequest,
        success: { encryptedRequest in
          XCTAssertFalse(
            encryptedRequest.encodedClientMetaInfo.isEmpty,
            "encodedClientMetaInfo should not be empty"
          )

          expectation.fulfill()
        },
        failure: { error in
          XCTFail("Encryption should succeed: \(error)")
          expectation.fulfill()
        }
      )
    }

    waitForExpectations(timeout: 15.0)
  }

  func testEncryptPaymentRequest_succeedsForAccountOnFileWithRequiredFields() {
    let expectation = expectation(description: "Encrypt account-on-file payment request")

    createSdkWithAccountOnFile { aofSdk, productWithAccountOnFile in
      guard let accountOnFile = productWithAccountOnFile.accountsOnFile.first else {
        XCTFail("Payment product should have at least one account on file")
        expectation.fulfill()
        return
      }

      let paymentRequest = PaymentRequest(
        paymentProduct: productWithAccountOnFile,
        accountOnFile: accountOnFile
      )

      do {
        try paymentRequest.setValue(id: "cvv", value: TestData.cvv)
      } catch {
        XCTFail("Should not fail setting required AoF field values: \(error)")
        expectation.fulfill()
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

          expectation.fulfill()
        },
        failure: { error in
          XCTFail("Encryption should succeed for account-on-file request: \(error)")
          expectation.fulfill()
        }
      )
    }

    waitForExpectations(timeout: 35.0)
  }

  func testEncryptPaymentRequest_throwsErrorWhenMandatoryFieldIsMissing() {
    let expectation = expectation(description: "Encrypt payment request with missing mandatory field")

    sdk.paymentProduct(
      withId: visaProductId,
      paymentContext: paymentContext,
      success: { paymentProduct in
        let paymentRequest = PaymentRequest(paymentProduct: paymentProduct)

        do {
          try paymentRequest.setValue(id: "cardholderName", value: "Test Cardholder")
          try paymentRequest.setValue(id: "cvv", value: TestData.cvv)
          try paymentRequest.setValue(id: "expiryDate", value: TestData.expiryDateMMYY)

          self.sdk.encryptPaymentRequest(
            paymentRequest,
            success: { _ in
              XCTFail("Should fail when mandatory field is missing")
              expectation.fulfill()
            },
            failure: { error in
              let invalidArgumentError = error as? InvalidArgumentError

              XCTAssertNotNil(
                invalidArgumentError,
                "Error should be an InvalidArgumentError"
              )

              XCTAssertEqual(
                "The payment request is not valid.",
                invalidArgumentError?.message
              )

              expectation.fulfill()
            }
          )
        } catch {
          XCTFail("Should not fail setting values: \(error)")
          expectation.fulfill()
        }
      },
      failure: { error in
        XCTFail("Should not fail getting product: \(error)")
        expectation.fulfill()
      }
    )

    waitForExpectations(timeout: 15.0)
  }

  func testEncryptPaymentRequest_throwsValidationErrorForInvalidCardNumber() {
    let expectation = expectation(description: "Encrypt payment request with invalid card number")

    sdk.paymentProduct(
      withId: visaProductId,
      paymentContext: paymentContext,
      success: { paymentProduct in
        let paymentRequest = PaymentRequest(paymentProduct: paymentProduct)

        do {
          try paymentRequest.setValue(id: "cardNumber", value: TestData.invalidCardNumber)
          try paymentRequest.setValue(id: "cardholderName", value: "Test Cardholder")
          try paymentRequest.setValue(id: "cvv", value: TestData.cvv)
          try paymentRequest.setValue(id: "expiryDate", value: TestData.expiryDateMMYY)

          self.sdk.encryptPaymentRequest(
            paymentRequest,
            success: { _ in
              XCTFail("Should fail for invalid card number")
              expectation.fulfill()
            },
            failure: { error in
              let invalidArgumentError = error as? InvalidArgumentError

              XCTAssertNotNil(
                invalidArgumentError,
                "Error should be an InvalidArgumentError"
              )

              XCTAssertEqual(
                "The payment request is not valid.",
                invalidArgumentError?.message
              )

              expectation.fulfill()
            }
          )
        } catch {
          XCTFail("Should not fail setting values: \(error)")
          expectation.fulfill()
        }
      },
      failure: { error in
        XCTFail("Should not fail getting product: \(error)")
        expectation.fulfill()
      }
    )

    waitForExpectations(timeout: 15.0)
  }

  func testGetPaymentProduct_calledTwice_shouldUseCacheOnSecondCall() {
    let firstExpectation = expectation(description: "First payment product call")
    let secondExpectation = expectation(description: "Second payment product call")

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
              "Cached result should have the same payment product ID"
            )

            XCTAssertEqual(
              firstResult.fields.count,
              secondResult.fields.count,
              "Cached result should have the same number of fields"
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

  func testPaymentRequest_preventsWritingReadOnlyAccountOnFileCardNumber() {
    let expectation = expectation(description: "Prevent writing read-only account-on-file card number")

    sdk.paymentProduct(
      withId: visaProductId,
      paymentContext: paymentContext,
      success: { paymentProduct in
        let accountOnFile = AccountOnFile(
          id: "test-account-on-file",
          paymentProductId: self.visaProductId,
          label: "Test account on file",
          attributes: [
            AccountOnFileAttribute(
              key: "cardNumber",
              value: "************4242",
              status: .readOnly
            ),
            AccountOnFileAttribute(
              key: "cvv",
              value: nil,
              status: .mustWrite
            )
          ]
        )

        let paymentRequest = PaymentRequest(
          paymentProduct: paymentProduct,
          accountOnFile: accountOnFile
        )

        do {
          try paymentRequest.setValue(id: "cardNumber", value: TestData.visaCardNumber)
          XCTFail("Should not allow writing read-only account-on-file card number")
        } catch let error as InvalidArgumentError {
          XCTAssertTrue(
            error.message.contains("Cannot write"),
            "Error should mention that read-only field cannot be written"
          )

          XCTAssertTrue(
            error.message.contains("cardNumber"),
            "Error should mention cardNumber"
          )
        } catch {
          XCTFail("Unexpected error: \(error)")
        }

        expectation.fulfill()
      },
      failure: { error in
        XCTFail("Should not fail getting product: \(error)")
        expectation.fulfill()
      }
    )

    waitForExpectations(timeout: 10.0)
  }

  // MARK: - Helper Methods

  private func createValidRequest(completion: @escaping (PaymentRequest) -> Void) {
    sdk.paymentProduct(
      withId: visaProductId,
      paymentContext: paymentContext,
      success: { paymentProduct in
        let paymentRequest = PaymentRequest(paymentProduct: paymentProduct)

        do {
          try paymentRequest.setValue(id: "cardNumber", value: TestData.visaCardNumberAlt)
          try paymentRequest.setValue(id: "cardholderName", value: "Test Cardholder")
          try paymentRequest.setValue(id: "cvv", value: TestData.cvv)
          try paymentRequest.setValue(
            id: "expiryDate",
            value: self.validExpiryDate(for: paymentProduct)
          )

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

  private func createSdkWithAccountOnFile(
    completion: @escaping (OnlinePaymentsSdk, PaymentProduct) -> Void
  ) {
    let tokenRequest = CreditCardTokenRequest()
    tokenRequest.cardNumber = TestData.visaCardNumberAlt
    tokenRequest.cardholderName = "Test Cardholder"
    tokenRequest.expiryDate = TestData.expiryDateMMYY
    tokenRequest.securityCode = TestData.cvv
    tokenRequest.paymentProductId = NSNumber(value: visaProductId)

    sdk.encryptTokenRequest(
      tokenRequest,
      success: { encryptedRequest in
        let createTokenRequest = CreateTokenRequest(
          encryptedCustomerInput: encryptedRequest.encryptedCustomerInput
        )

        self.serverApi.createToken(request: createTokenRequest) { tokenResult in
          switch tokenResult {
          case .success(let tokenResponse):
            guard let token = tokenResponse.token else {
              XCTFail("Token should not be nil")
              return
            }

            self.createSessionWithToken(token) { sessionData in
              guard let aofSdk = try? OnlinePaymentsSdk(
                sessionData: sessionData,
                configuration: SdkConfiguration(
                  appIdentifier: "SwiftSDK/IntegrationTests"
                )
              ) else {
                XCTFail("Failed to create SDK with account-on-file session")
                return
              }

              aofSdk.paymentProduct(
                withId: self.visaProductId,
                paymentContext: self.paymentContext,
                success: { paymentProduct in
                  completion(aofSdk, paymentProduct)
                },
                failure: { error in
                  XCTFail("Failed to fetch product with AoF: \(error)")
                }
              )
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

  private func createSessionWithToken(
    _ token: String,
    completion: @escaping (SessionData) -> Void
  ) {
    let sessionRequest = CreateSessionRequest(tokens: [token])

    serverApi.createSession(request: sessionRequest) { sessionResult in
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

        completion(sessionData)

      case .failure(let error):
        XCTFail("Failed to create session with token: \(error)")
      }
    }
  }

  private func validExpiryDate(for paymentProduct: PaymentProduct) -> String {
    guard let expiryField = paymentProduct.field(id: "expiryDate") else {
      return TestData.expiryDateMMYY
    }

    let maskedValue = expiryField.applyMask(value: "122030")

    return maskedValue?.count == 5
      ? TestData.expiryDateMMYY
      : "122030"
  }
}
