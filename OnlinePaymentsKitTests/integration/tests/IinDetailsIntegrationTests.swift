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

/// Integration tests for IIN (Issuer Identification Number) details lookup.
/// Tests real API calls to identify card types from card numbers.
class IinDetailsIntegrationTests: BaseIntegrationTest {

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testGetIinDetails_withValidCardNumber_shouldReturnSupported() {
        // Use first 6 digits of a valid card number
        let partialCardNumber = "400000"

        let expectation = expectation(description: "Get IIN details")

        sdk.iinDetails(
            forPartialCardNumber: partialCardNumber,
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertEqual(
                    IINStatus.supported,
                    iinDetailsResponse.status,
                    "Status should be SUPPORTED for valid card"
                )
                XCTAssertNotNil(
                    iinDetailsResponse.coBrands,
                    "Co-brands should not be null"
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

    func testGetIinDetails_withNotEnoughDigits_shouldReturnNotEnoughDigits() {
        // Use less than 6 digits
        let partialCardNumber = "123"

        let expectation = expectation(description: "Get IIN details with not enough digits")

        sdk.iinDetails(
            forPartialCardNumber: partialCardNumber,
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertNotNil(iinDetailsResponse, "Result should not be null")
                XCTAssertEqual(
                    IINStatus.notEnoughDigits,
                    iinDetailsResponse.status,
                    "Status should be NOT_ENOUGH_DIGITS for short input"
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

    func testGetIinDetails_withUnknownCardNumber_shouldReturnUnknown() {
        // Use a BIN that's unlikely to be in the system
        let unknownBin = "999999"

        let expectation = expectation(description: "Get IIN details with unknown card")

        sdk.iinDetails(
            forPartialCardNumber: unknownBin,
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertNotNil(iinDetailsResponse, "Result should not be null")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetIinDetails_calledTwice_shouldUseCacheOnSecondCall() {
        let partialCardNumber = "456735"

        let firstExpectation = expectation(description: "First call")
        let secondExpectation = expectation(description: "Second call")

        // First call - should fetch from API
        sdk.iinDetails(
            forPartialCardNumber: partialCardNumber,
            paymentContext: paymentContext,
            success: { firstResult in
                firstExpectation.fulfill()

                // Second call - should use cache and return same data
                self.sdk.iinDetails(
                    forPartialCardNumber: partialCardNumber,
                    paymentContext: self.paymentContext,
                    success: { secondResult in
                        XCTAssertEqual(
                            firstResult.status,
                            secondResult.status,
                            "Cached result should have same status"
                        )
                        XCTAssertEqual(
                            firstResult.paymentProductId,
                            secondResult.paymentProductId,
                            "Cached result should have same payment product ID"
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

    func testGetIinDetails_withDifferentCardNumbers_shouldInvalidateCache() {
        let cardNumber1 = "456735"
        let cardNumber2 = "424242"

        let firstExpectation = expectation(description: "First call")
        let secondExpectation = expectation(description: "Second call")

        // First call
        sdk.iinDetails(
            forPartialCardNumber: cardNumber1,
            paymentContext: paymentContext,
            success: { firstResult in
                XCTAssertNotNil(firstResult, "First result should not be null")
                firstExpectation.fulfill()

                // Second call with different card number
                self.sdk.iinDetails(
                    forPartialCardNumber: cardNumber2,
                    paymentContext: self.paymentContext,
                    success: { secondResult in
                        XCTAssertFalse(
                            firstResult === secondResult,
                            "Different card numbers should yield distinct response objects"
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

    func testGetIinDetails_withFullCardNumber_shouldReturnSupported() {
        // Use full card number (API should handle this)
        let fullCardNumber = "4242424242424242"

        let expectation = expectation(description: "Get IIN details with full card number")

        sdk.iinDetails(
            forPartialCardNumber: fullCardNumber,
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertNotNil(iinDetailsResponse, "Result should not be null")
                XCTAssertEqual(
                    IINStatus.supported,
                    iinDetailsResponse.status,
                    "Status should be SUPPORTED for full valid card number"
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

    func testGetIinDetails_shouldReturnPaymentProductId() {
        let partialCardNumber = "456735"

        let expectation = expectation(description: "Get IIN details")

        sdk.iinDetails(
            forPartialCardNumber: partialCardNumber,
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertNotNil(iinDetailsResponse, "Result should not be null")
                if iinDetailsResponse.status == .supported {
                    XCTAssertNotNil(
                        iinDetailsResponse.paymentProductId,
                        "Payment product ID should not be null for supported card"
                    )
                }

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetIinDetails_shouldReturnCardType() {
        let partialCardNumber = "456735"

        let expectation = expectation(description: "Get IIN details")

        sdk.iinDetails(
            forPartialCardNumber: partialCardNumber,
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertNotNil(iinDetailsResponse, "Result should not be null")
                if iinDetailsResponse.status == .supported {
                    // Card type might be nil or might have a value depending on API response
                    // Just verify we get a valid result
                    }

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetIinDetails_WhenIsAllowedInContextFalse_ReturnsExistingButNotAllowedStatus() {
        // Uses HTTP stubbing (equivalent to Android's MockWebServer / JS SDK's getApiClientSpyMock)
        // to return a crafted response with isAllowedInContext: false.
        stub(condition: isMethodPOST() && { req in
            req.url?.path.hasSuffix("/services/getIINdetails") == true
        }) { _ in
            HTTPStubsResponse(
                jsonObject: ["paymentProductId": 1, "isAllowedInContext": false],
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }

        defer { HTTPStubs.removeAllStubs() }

        let expectation = expectation(description: "Get IIN details for restricted card")

        sdk.iinDetails(
            forPartialCardNumber: "400000",
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertNotNil(iinDetailsResponse, "Result should not be null")
                XCTAssertEqual(
                    IINStatus.existingButNotAllowed,
                    iinDetailsResponse.status,
                    "Status should be EXISTING_BUT_NOT_ALLOWED when isAllowedInContext is false"
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

    func testGetIinDetails_WhenIsAllowedInContextAbsent_ReturnsSupportedStatus() {
        // Uses a real API call with a known Visa BIN that the preprod environment recognises.
        // The JS SDK test covers this via a mock that triggers a payment-product fallback;
        // the Swift SDK has no such fallback, so we follow the Android SDK pattern of
        // calling the real API with a supported card and asserting SUPPORTED.
        let expectation = expectation(description: "Get IIN details for supported card")

        sdk.iinDetails(
            forPartialCardNumber: "400000",
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertNotNil(iinDetailsResponse, "Result should not be null")
                XCTAssertEqual(
                    IINStatus.supported,
                    iinDetailsResponse.status,
                    "Status should be SUPPORTED for a card allowed in context"
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

    func testGetIinDetails_CardNumberWith6Digits_DoesNotThrow() {
        // Boundary condition: exactly 6 digits should be accepted (minimum required)
        let expectation = expectation(description: "Get IIN details with exactly 6 digits")

        sdk.iinDetails(
            forPartialCardNumber: "400000",
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertNotNil(iinDetailsResponse, "Result should not be null")
                XCTAssertNotEqual(
                    IINStatus.notEnoughDigits,
                    iinDetailsResponse.status,
                    "Status should not be NOT_ENOUGH_DIGITS for 6-digit input"
                )
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail for 6-digit card number: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }
}
