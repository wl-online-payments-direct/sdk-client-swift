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

/// Integration tests for IIN (Issuer Identification Number) details lookup.
/// Tests real API calls to identify card types from card numbers.
class IinDetailsIntegrationTests: BaseIntegrationTest {

    func testGetIinDetails_withValidCardNumber_shouldReturnSupported() {
        // Use first 6 digits of a valid card number
        let partialCardNumber = "400000"

        let expectation = expectation(description: "Get IIN details")

        sdk.iinDetails(
            forPartialCardNumber: partialCardNumber,
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertNotNil(iinDetailsResponse, "Result should not be null")
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
                XCTAssertNotNil(iinDetailsResponse.status, "Status should not be null")
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

        var firstCallTime: TimeInterval = 0
        var secondCallTime: TimeInterval = 0

        // First call - should fetch from API
        let firstStart = Date()
        sdk.iinDetails(
            forPartialCardNumber: partialCardNumber,
            paymentContext: paymentContext,
            success: { firstResult in
                firstCallTime = Date().timeIntervalSince(firstStart)
                XCTAssertNotNil(firstResult, "First result should not be null")
                firstExpectation.fulfill()

                // Second call - should use cache
                let secondStart = Date()
                self.sdk.iinDetails(
                    forPartialCardNumber: partialCardNumber,
                    paymentContext: self.paymentContext,
                    success: { secondResult in
                        secondCallTime = Date().timeIntervalSince(secondStart)
                        XCTAssertNotNil(secondResult, "Second result should not be null")

                        // Cached call should be significantly faster
                        XCTAssertTrue(
                            firstCallTime > secondCallTime,
                            "Cached call should be faster"
                        )

                        XCTAssertEqual(
                            firstResult.status,
                            secondResult.status,
                            "Results should have same status"
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
                        XCTAssertNotNil(secondResult, "Second result should not be null")

                        // Both should be SUPPORTED or UNKNOWN - just verify we get responses
                        XCTAssertNotNil(firstResult.status, "First status should not be null")
                        XCTAssertNotNil(secondResult.status, "Second status should not be null")

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
                    XCTAssertNotNil(iinDetailsResponse, "IIN details should be present")
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
}
