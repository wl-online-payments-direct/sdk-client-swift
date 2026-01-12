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

class PaymentProductServiceTestCase: XCTestCase {
    
    var paymentProductService: PaymentProductService!
    var mockApiClient: ApiClientMock!
    var mockCacheManager: CacheManagerMock!
    var sessionData: SessionData!
    var paymentContext: PaymentContext!
    
    override func setUp() {
        super.setUp()
        
        mockApiClient = ApiClientMock()
        mockCacheManager = CacheManagerMock()
        
        sessionData = SessionData(
            clientSessionId: "test-session-123",
            customerId: "testid",
            clientApiUrl: "https://api.test.com",
            assetUrl: "https://assets.test.com"
        )
        
        paymentProductService = PaymentProductService(
            apiClient: mockApiClient,
            cacheManager: mockCacheManager,
            sessionData: sessionData
        )
        
        paymentContext = PaymentContext(
            amountOfMoney: AmountOfMoney(amount: 100, currencyCode: "EUR"),
            isRecurring: false,
            countryCode: "NL"
        )
    }
    
    override func tearDown() {
        paymentProductService = nil
        mockApiClient = nil
        mockCacheManager = nil
        sessionData = nil
        paymentContext = nil
        super.tearDown()
    }
    
    func testGetBasicPaymentProductsReturnsProductsSuccessfully() {
        let expectation = self.expectation(description: "Get payment products succeeds")
        
        let products = try! FixtureLoader.loadJSON("basicPaymentProducts", as: BasicPaymentProductsDto.self)
        let networks = try! FixtureLoader.loadJSON("paymentProductNetworks", as: PaymentProductNetworks.self)
        
        mockApiClient.mockGetResponses["/products"] = products
        mockApiClient.mockGetResponses["/products/\(SupportedProductsUtil.kApplePayIdentifier)/networks"] = networks
        
        paymentProductService.paymentProducts(
            forContext: paymentContext,
            success: { result in
                XCTAssertNotNil(result)
                XCTAssertFalse(result.paymentProducts.isEmpty)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error.message)")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetBasicPaymentProductsFiltersOutUnsupportedProducts() {
        let expectation = self.expectation(description: "Filters unsupported products")
        
        let products = try! FixtureLoader.loadJSON("basicPaymentProducts", as: BasicPaymentProductsDto.self)
        let networks = try! FixtureLoader.loadJSON("paymentProductNetworks", as: PaymentProductNetworks.self)

        mockApiClient.mockGetResponses["/products"] = products
        mockApiClient.mockGetResponses["/products/\(SupportedProductsUtil.kApplePayIdentifier)/networks"] = networks
        
        paymentProductService.paymentProducts(
            forContext: paymentContext,
            success: { result in
                let hasUnsupported = result.paymentProducts.contains { product in
                    guard let id = product.id else { return false }
                    return SupportedProductsUtil.sdkUnsupportedProducts.contains(id)
                }
                XCTAssertFalse(hasUnsupported, "Should not contain unsupported products")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetPaymentProductReturnsProductSuccessfully() {
        let expectation = self.expectation(description: "Get payment product succeeds")
        
        let product = try! FixtureLoader.loadJSON("cardPaymentProduct", as: PaymentProductDto.self)
        mockApiClient.mockGetResponses["/products/1"] = product
        
        paymentProductService.paymentProduct(
            withId: 1,
            forContext: paymentContext,
            success: { result in
                XCTAssertNotNil(result)
                XCTAssertEqual(result.id, 1)
                XCTAssertFalse(result.fields.isEmpty)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetPaymentProductReturnsProductWithFieldsSortedByDisplayOrder() {
        let expectation = self.expectation(description: "Fields sorted by display order")
        
        let product = try! FixtureLoader.loadJSON("cardPaymentProduct", as: PaymentProductDto.self)
        mockApiClient.mockGetResponses["/products/1"] = product
        
        paymentProductService.paymentProduct(
            withId: 1,
            forContext: paymentContext,
            success: { result in
                XCTAssertEqual(result.fields.count, 4)
                XCTAssertEqual(result.fields[0].id, "cardNumber")
                XCTAssertEqual(result.fields[1].id, "cardholderName")
                XCTAssertEqual(result.fields[2].id, "expiryDate")
                XCTAssertEqual(result.fields[3].id, "cvv")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetPaymentProductReturnsProductWithLabelAndLogo() {
        let expectation = self.expectation(description: "Product has label and logo")
        
        let product = try! FixtureLoader.loadJSON("cardPaymentProduct", as: PaymentProductDto.self)
        mockApiClient.mockGetResponses["/products/1"] = product
        
        paymentProductService.paymentProduct(
            withId: 1,
            forContext: paymentContext,
            success: { result in
                XCTAssertEqual(result.label, "VISA")
                XCTAssertEqual(result.logo, "test-logo")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetPaymentProductReturnsErrorForUnsupportedProduct() {
        let expectation = self.expectation(description: "Returns error for unsupported product")
        
        paymentProductService.paymentProduct(
            withId: 5772,
            forContext: paymentContext,
            success: { _ in
                XCTFail("Should not succeed")
            },
            failure: { error in
                print(error.message, error.code)
                print("****")
                XCTAssertTrue(error is ResponseError)
                if let responseError = error as? ResponseError {
                    XCTAssertEqual(responseError.httpStatusCode, 404)
                    XCTAssertEqual(responseError.message, "Product not found or not available.")
                    // Check if metadata contains ErrorResponse using the helper property
                    XCTAssertNotNil(responseError.metadata)
                }
                expectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetPaymentProductReturnsErrorOnApiFailure() {
        let expectation = self.expectation(description: "Returns error on API failure")
        
        mockApiClient.shouldGetFail = true
        mockApiClient.mockGetError = ResponseError(
            httpStatusCode: 500,
            message: "Network error",
            data: nil
        )
        
        paymentProductService.paymentProduct(
            withId: 1,
            forContext: paymentContext,
            success: { _ in
                XCTFail("Should not succeed")
            },
            failure: { error in
                XCTAssertTrue(error is ResponseError)
                if let responseError = error as? ResponseError {
                    XCTAssertEqual(responseError.httpStatusCode, 500)
                    XCTAssertEqual(responseError.message, "Network error")
                }
                expectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetPaymentProductNetworksReturnsNetworksSuccessfully() {
        let expectation = self.expectation(description: "Get networks succeeds")
        
        let networks = try! FixtureLoader.loadJSON("paymentProductNetworks", as: PaymentProductNetworks.self)
        mockApiClient.mockGetResponses["/products/1/networks"] = networks
        
        paymentProductService.paymentProductNetworks(
            forProductId: 1,
            forContext: paymentContext,
            success: { result in
                XCTAssertNotNil(result)
                XCTAssertEqual(result.paymentProductNetworks.count, 2)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetBasicPaymentProductsUsesCacheOnSecondCall() {
        let expectation1 = self.expectation(description: "First call")
        let expectation2 = self.expectation(description: "Second call")
        
        let products = try! FixtureLoader.loadJSON("basicPaymentProducts", as: BasicPaymentProductsDto.self)
        let networks = try! FixtureLoader.loadJSON("paymentProductNetworks", as: PaymentProductNetworks.self)

        mockApiClient.mockGetResponses["/products"] = products
        mockApiClient.mockGetResponses["/products/\(SupportedProductsUtil.kApplePayIdentifier)/networks"] = networks
        
        paymentProductService.paymentProducts(
            forContext: paymentContext,
            success: { _ in
                expectation1.fulfill()
            },
            failure: { _ in
                XCTFail("Should not fail")
            }
        )
        
        wait(for: [expectation1], timeout: 2.0)
        
        let apiCallCount = mockApiClient.getCallCount
        
        paymentProductService.paymentProducts(
            forContext: paymentContext,
            success: { _ in
                XCTAssertEqual(self.mockApiClient.getCallCount, apiCallCount, "Should not call API again")
                expectation2.fulfill()
            },
            failure: { _ in
                XCTFail("Should not fail")
            }
        )
        
        wait(for: [expectation2], timeout: 2.0)
    }
    
    func testGetBasicPaymentProductsCacheInvalidatesWithDifferentContext() {
        let expectation1 = self.expectation(description: "First call")
        let expectation2 = self.expectation(description: "Second call")
        
        let products = try! FixtureLoader.loadJSON("basicPaymentProducts", as: BasicPaymentProductsDto.self)
        let networks = try! FixtureLoader.loadJSON("paymentProductNetworks", as: PaymentProductNetworks.self)

        mockApiClient.mockGetResponses["/products"] = products
        mockApiClient.mockGetResponses["/products/\(SupportedProductsUtil.kApplePayIdentifier)/networks"] = networks
        
        paymentProductService.paymentProducts(
            forContext: paymentContext,
            success: { _ in
                expectation1.fulfill()
            },
            failure: { _ in
                XCTFail("Should not fail")
            }
        )
        
        wait(for: [expectation1], timeout: 2.0)
        
        let firstCallCount = mockApiClient.getCallCount
        
        let differentContext = PaymentContext(
            amountOfMoney: AmountOfMoney(amount: 200, currencyCode: "EUR"),
            isRecurring: false,
            countryCode: "NL"
        )
        
        paymentProductService.paymentProducts(
            forContext: differentContext,
            success: { _ in
                XCTAssertGreaterThan(self.mockApiClient.getCallCount, firstCallCount, "Should call API again")
                expectation2.fulfill()
            },
            failure: { _ in
                XCTFail("Should not fail")
            }
        )
        
        wait(for: [expectation2], timeout: 2.0)
    }
    
    func testGetPaymentProductCacheInvalidatesWithDifferentContext() {
        let expectation1 = self.expectation(description: "First call")
        let expectation2 = self.expectation(description: "Second call")
        
        let product = try! FixtureLoader.loadJSON("cardPaymentProduct", as: PaymentProductDto.self)
        mockApiClient.mockGetResponses["/products/1"] = product
        
        paymentProductService.paymentProduct(
            withId: 1,
            forContext: paymentContext,
            success: { _ in
                expectation1.fulfill()
            },
            failure: { _ in
                XCTFail("Should not fail")
            }
        )
        
        wait(for: [expectation1], timeout: 2.0)
        
        let firstCallCount = mockApiClient.getCallCount
        
        let differentContext = PaymentContext(
            amountOfMoney: AmountOfMoney(amount: 100, currencyCode: "EUR"),
            isRecurring: false,
            countryCode: "DE"
        )
        
        paymentProductService.paymentProduct(
            withId: 1,
            forContext: differentContext,
            success: { _ in
                XCTAssertGreaterThan(self.mockApiClient.getCallCount, firstCallCount, "Should call API again")
                expectation2.fulfill()
            },
            failure: { _ in
                XCTFail("Should not fail")
            }
        )
        
        wait(for: [expectation2], timeout: 2.0)
    }
    
    func testGetBasicPaymentProductsLoadsLogosForProducts() {
        let expectation = self.expectation(description: "Logos are loaded")
        
        let products = try! FixtureLoader.loadJSON("basicPaymentProducts", as: BasicPaymentProductsDto.self)
        let networks = try! FixtureLoader.loadJSON("paymentProductNetworks", as: PaymentProductNetworks.self)
        
        mockApiClient.mockGetResponses["/products"] = products
        mockApiClient.mockGetResponses["/products/\(SupportedProductsUtil.kApplePayIdentifier)/networks"] = networks
        
        paymentProductService.paymentProducts(
            forContext: paymentContext,
            success: { result in
                // Check that products have logo paths
                let productsWithLogos = result.paymentProducts.filter { $0.logo != nil }
                XCTAssertFalse(productsWithLogos.isEmpty, "Should have products with logo paths")
                
                for product in productsWithLogos {
                    XCTAssertNotNil(product.logo, "Product should have logo path")
                }
                
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error.message)")
            }
        )
        
        waitForExpectations(timeout: 5.0) // Longer timeout for image loading
    }
}
