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

/// Integration tests for getting basic payment products.
/// Tests real API calls to the preprod environment.
class BasicPaymentProductsIntegrationTests: BaseIntegrationTest {

    func testGetBasicPaymentProducts_shouldReturnBasicPaymentProducts() {
        let expectation = expectation(description: "Get basic payment products")

        sdk.basicPaymentProducts(
            forContext: paymentContext,
            success: { basicPaymentProducts in
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

    func testGetBasicPaymentProducts_withInvalidAmount_shouldReturnError() {
        let invalidContext = createPaymentContext(amount: -1)

        let expectation = expectation(description: "Get basic payment products with invalid amount")

        sdk.basicPaymentProducts(
            forContext: invalidContext,
            success: { _ in
                XCTFail("Should have failed for invalid amount")
                expectation.fulfill()
            },
            failure: { error in
                let responseError = error as? ResponseError
                XCTAssertNotNil(responseError, "Error should be a ResponseError")
                XCTAssertEqual(responseError?.httpStatusCode, 404)
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetBasicPaymentProducts_calledTwice_shouldUseCacheOnSecondCall() {
        let firstExpectation = expectation(description: "First call")
        let secondExpectation = expectation(description: "Second call")

        // First call - should fetch from API
        sdk.basicPaymentProducts(
            forContext: paymentContext,
            success: { firstResult in
                firstExpectation.fulfill()

                // Second call - should use cache and return same data
                self.sdk.basicPaymentProducts(
                    forContext: self.paymentContext,
                    success: { secondResult in
                        XCTAssertEqual(
                            firstResult.paymentProducts.count,
                            secondResult.paymentProducts.count,
                            "Cached result should have same number of products"
                        )
                        
                        XCTAssertEqual(
                            firstResult.paymentProducts.map { $0.id },
                            secondResult.paymentProducts.map { $0.id },
                            "Cached result should have same product IDs"
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
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }
}
