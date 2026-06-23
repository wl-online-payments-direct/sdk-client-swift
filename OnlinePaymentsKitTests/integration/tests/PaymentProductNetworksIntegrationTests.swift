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

/// Integration tests for getPaymentProductNetworks.
/// Tests real API calls to the preprod environment.
class PaymentProductNetworksIntegrationTests: BaseIntegrationTest {

    private let googlePayProductId = 320

    func testGetPaymentProductNetworks_WrongProductId_ThrowsResponseError() {
        let productId = 1  // VISA — does not support networks
        let expectation = expectation(description: "Get networks for wrong product")

        sdk.paymentProductNetworks(
            forProductId: productId,
            paymentContext: paymentContext,
            success: { _ in
                XCTFail("Should not succeed for a product that does not support networks")
                expectation.fulfill()
            },
            failure: { error in
                XCTAssertTrue(
                    error is ResponseError,
                    "Error should be a ResponseError"
                )

                if let responseError = error as? ResponseError {
                    XCTAssertNotNil(
                        responseError.httpStatusCode,
                        "Response error should have an HTTP status code"
                    )
                }

                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetPaymentProductNetworks_ValidProductId_ReturnsNetworksList() {
        let expectation = expectation(description: "Get networks for Google Pay")

        sdk.paymentProductNetworks(
            forProductId: googlePayProductId,
            paymentContext: paymentContext,
            success: { networks in
                XCTAssertFalse(
                    networks.paymentProductNetworks.isEmpty,
                    "Google Pay should return a non-empty networks list"
                )

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail for Google Pay networks: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetPaymentProductNetworks_WhenCalledAgain_ReturnsCachedResult() {
        let firstExpectation = expectation(description: "First call")
        let secondExpectation = expectation(description: "Second call")

        sdk.paymentProductNetworks(
            forProductId: googlePayProductId,
            paymentContext: paymentContext,
            success: { firstResult in
                firstExpectation.fulfill()

                self.sdk.paymentProductNetworks(
                    forProductId: self.googlePayProductId,
                    paymentContext: self.paymentContext,
                    success: { secondResult in
                        XCTAssertEqual(
                            firstResult.paymentProductNetworks,
                            secondResult.paymentProductNetworks,
                            "Cached result should have same networks"
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

    func testGetPaymentProductNetworks_WithDifferentContext_ShouldInvalidateCache() {
        let firstExpectation = expectation(description: "First call")
        let secondExpectation = expectation(description: "Second call")

        sdk.paymentProductNetworks(
            forProductId: googlePayProductId,
            paymentContext: paymentContext,
            success: { firstResult in
                firstExpectation.fulfill()

                let usdContext = self.createPaymentContext(amount: 1000, currencyCode: "USD")

                self.sdk.paymentProductNetworks(
                    forProductId: self.googlePayProductId,
                    paymentContext: usdContext,
                    success: { secondResult in
                        XCTAssertFalse(
                            secondResult.paymentProductNetworks.isEmpty,
                            "Second result should also contain networks"
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
