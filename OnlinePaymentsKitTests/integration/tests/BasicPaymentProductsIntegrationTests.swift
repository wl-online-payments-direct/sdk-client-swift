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

/// Integration tests for getting basic payment products.
/// Tests real API calls to the preprod environment.
class BasicPaymentProductsIntegrationTests: BaseIntegrationTest {

    func testGetBasicPaymentProducts_shouldReturnBasicPaymentProducts() {
        let expectation = expectation(description: "Get basic payment products")

        sdk.basicPaymentProducts(
            forContext: paymentContext,
            success: { basicPaymentProducts in
                XCTAssertNotNil(basicPaymentProducts, "Result should not be null")
                XCTAssertFalse(
                    basicPaymentProducts.paymentProducts.isEmpty,
                    "Should have at least one payment product"
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

    func testGetPaymentProduct_shouldReturnPaymentProduct() {
        let productId = 1  // VISA

        let expectation = expectation(description: "Get payment product")

        sdk.paymentProduct(
            withId: productId,
            paymentContext: paymentContext,
            success: { paymentProduct in
                XCTAssertNotNil(paymentProduct, "Result should not be null")
                XCTAssertEqual(
                    productId,
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

    func testGetBasicPaymentProducts_withInvalidAmount_shouldReturnEmpty() {
        let invalidContext = createPaymentContext(amount: -1)

        let expectation = expectation(description: "Get basic payment products with invalid amount")

        sdk.basicPaymentProducts(
            forContext: invalidContext,
            success: { basicPaymentProducts in
                XCTAssertEqual(0, basicPaymentProducts.paymentProducts.count)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetBasicPaymentProducts_calledTwice_shouldUseCacheOnSecondCall() {
        let firstExpectation = expectation(description: "First call")
        let secondExpectation = expectation(description: "Second call")

        var firstCallTime: TimeInterval = 0
        var secondCallTime: TimeInterval = 0

        // First call - should fetch from API
        let firstStart = Date()
        sdk.basicPaymentProducts(
            forContext: paymentContext,
            success: { firstResult in
                firstCallTime = Date().timeIntervalSince(firstStart)
                XCTAssertNotNil(firstResult, "First result should not be null")
                firstExpectation.fulfill()

                // Second call - should use cache
                let secondStart = Date()
                self.sdk.basicPaymentProducts(
                    forContext: self.paymentContext,
                    success: { secondResult in
                        secondCallTime = Date().timeIntervalSince(secondStart)
                        XCTAssertNotNil(secondResult, "Second result should not be null")

                        // Cached call should be significantly faster
                        XCTAssertTrue(
                            secondCallTime < 0.1,  // Less than 100ms for cached call
                            "Second call should be faster (cached): \(secondCallTime)s"
                        )
                        XCTAssertTrue(
                            secondCallTime < firstCallTime,
                            "Second call should be faster (cached): \(secondCallTime)s"
                        )

                        XCTAssertEqual(
                            firstResult.paymentProducts.count,
                            secondResult.paymentProducts.count,
                            "Results should have same number of products"
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

    func testGetBasicPaymentProducts_withDifferentContext_shouldInvalidateCache() {
        let firstExpectation = expectation(description: "First call")
        let secondExpectation = expectation(description: "Second call")

        // First call with EUR
        sdk.basicPaymentProducts(
            forContext: paymentContext,
            success: { firstResult in
                XCTAssertNotNil(firstResult, "First result should not be null")
                firstExpectation.fulfill()

                // Second call with USD - different context should invalidate cache
                let usdContext = self.createPaymentContext(amount: 1000, currencyCode: "USD")
                self.sdk.basicPaymentProducts(
                    forContext: usdContext,
                    success: { secondResult in
                        XCTAssertNotNil(secondResult, "Second result should not be null")
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

    func testGetPaymentProduct_shouldHaveDisplayHints() {
        let productId = 1  // VISA

        let expectation = expectation(description: "Get payment product")

        sdk.paymentProduct(
            withId: productId,
            paymentContext: paymentContext,
            success: { paymentProduct in
                XCTAssertNotNil(paymentProduct, "Result should not be null")
                XCTAssertNotNil(paymentProduct.logo, "Result should have logo")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetPaymentProduct_shouldHavePaymentProductFields() {
        let productId = 1  // VISA

        let expectation = expectation(description: "Get payment product")

        sdk.paymentProduct(
            withId: productId,
            paymentContext: paymentContext,
            success: { paymentProduct in
                XCTAssertNotNil(paymentProduct, "Result should not be null")
                XCTAssertFalse(paymentProduct.fields.isEmpty, "Should have payment product fields")

                // Verify card products have expected fields
                let fieldIds = paymentProduct.fields.map { $0.id }
                XCTAssertTrue(
                    fieldIds.contains("cardNumber"),
                    "Card product should have cardNumber field"
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

    func testGetPaymentProduct_nonExistentProduct_shouldThrowException() {
        let nonExistentProductId = 99999

        let expectation = expectation(description: "Get non-existent payment product")

        sdk.paymentProduct(
            withId: nonExistentProductId,
            paymentContext: paymentContext,
            success: { _ in
                XCTFail("Should have thrown an exception for non-existent product")
                expectation.fulfill()
            },
            failure: { error in
                // Expected - server returns error for non-existent products
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }
}
