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

/// Integration tests for getting basic payment products.
/// Tests real API calls to the preprod environment.
class BasicPaymentProductsIntegrationTests: BaseIntegrationTest {

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

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
                XCTAssertNotNil(firstResult, "First result should not be nil")
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
                XCTAssertTrue(
                    (responseError?.httpStatusCode ?? 0) >= 400,
                    "Invalid amount should return an error status"
                )

                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetBasicPaymentProducts_filtersProductsNotSupportedBySDK() {
        stubProductsResponse(
            jsonObject: [
                "paymentProducts": [
                    [
                        "id": 1,
                        "paymentMethod": "card"
                    ],
                    [
                        "id": 117,
                        "paymentMethod": "card"
                    ]
                ]
            ]
        )

        let expectation = expectation(description: "Filter products not supported by SDK")

        sdk.basicPaymentProducts(
            forContext: paymentContext,
            success: { basicPaymentProducts in
                let productIds = basicPaymentProducts.paymentProducts.compactMap { $0.id }

                XCTAssertTrue(productIds.contains(1), "Supported product should remain available")
                XCTAssertFalse(productIds.contains(117), "SDK-unsupported product should be filtered out")

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }
    
    func testGetBasicPaymentProducts_whenNoPaymentProductsAreAvailable_shouldReturnError() {
        stubProductsResponse(
            jsonObject: [
                "paymentProducts": []
            ]
        )

        let expectation = expectation(description: "No payment products available")

        sdk.basicPaymentProducts(
            forContext: paymentContext,
            success: { _ in
                XCTFail("Should fail when no payment products are available")
                expectation.fulfill()
            },
            failure: { error in
                let responseError = error as? ResponseError

                XCTAssertNotNil(responseError, "Error should be a ResponseError")
                XCTAssertEqual(404, responseError?.httpStatusCode)
                XCTAssertEqual("No payment products available.", responseError?.message)

                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetBasicPaymentProducts_with503Response_shouldReturnResponseError() {
        stubProductsResponse(
            jsonObject: [
                "errorId": "SERVER_ERROR",
                "errors": []
            ],
            statusCode: 503
        )

        let expectation = expectation(description: "503 response")

        sdk.basicPaymentProducts(
            forContext: paymentContext,
            success: { _ in
                XCTFail("Should fail for 503 response")
                expectation.fulfill()
            },
            failure: { error in
                let responseError = error as? ResponseError

                XCTAssertNotNil(responseError, "Error should be a ResponseError")
                XCTAssertEqual(503, responseError?.httpStatusCode)

                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetBasicPaymentProducts_withMalformedJSON_shouldReturnCommunicationError() {
        let invalidJsonData = "not-valid-json".data(using: .utf8)!

        stubProductsDataResponse(data: invalidJsonData)

        let expectation = expectation(description: "Malformed JSON")

        sdk.basicPaymentProducts(
            forContext: paymentContext,
            success: { _ in
                XCTFail("Should fail for malformed JSON")
                expectation.fulfill()
            },
            failure: { error in
                XCTAssertTrue(
                    error is CommunicationError,
                    "Error should be a CommunicationError"
                )

                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetBasicPaymentProducts_withNetworkFailure_shouldReturnCommunicationError() {
        stubProductsNetworkFailure()

        let expectation = expectation(description: "Network failure")

        sdk.basicPaymentProducts(
            forContext: paymentContext,
            success: { _ in
                XCTFail("Should fail for network failure")
                expectation.fulfill()
            },
            failure: { error in
                XCTAssertTrue(
                    error is CommunicationError,
                    "Error should be a CommunicationError"
                )

                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    private func stubProductsResponse(
        jsonObject: [String: Any],
        statusCode: Int32 = 200
    ) {
        stub(condition: isMethodGET() && { request in
            request.url?.path.hasSuffix("/products") == true
        }) { _ in
            HTTPStubsResponse(
                jsonObject: jsonObject,
                statusCode: statusCode,
                headers: ["Content-Type": "application/json"]
            )
        }
    }

    private func stubProductsDataResponse(
        data: Data,
        statusCode: Int32 = 200
    ) {
        stub(condition: isMethodGET() && { request in
            request.url?.path.hasSuffix("/products") == true
        }) { _ in
            HTTPStubsResponse(
                data: data,
                statusCode: statusCode,
                headers: ["Content-Type": "application/json"]
            )
        }
    }

    private func stubProductsNetworkFailure() {
        stub(condition: isMethodGET() && { request in
            request.url?.path.hasSuffix("/products") == true
        }) { _ in
            HTTPStubsResponse(
                error: NSError(
                    domain: NSURLErrorDomain,
                    code: NSURLErrorNotConnectedToInternet,
                    userInfo: nil
                )
            )
        }
    }
}
