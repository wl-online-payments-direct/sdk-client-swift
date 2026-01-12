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

class ClientServiceTestCase: XCTestCase {
    
    var clientService: ClientService!
    var mockApiClient: ApiClientMock!
    var mockCacheManager: CacheManagerMock!
    var sessionData: SessionData!
    var paymentContext: PaymentContext!
    var amountOfMoney: AmountOfMoney!
    var cardSource: CardSource!
    
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
        
        clientService = ClientService(
            apiClient: mockApiClient,
            cacheManager: mockCacheManager,
            sessionData: sessionData
        )
        
        paymentContext = PaymentContext(
            amountOfMoney: AmountOfMoney(amount: 1000, currencyCode: "EUR"),
            isRecurring: false,
            countryCode: "NL"
        )
        
        amountOfMoney = AmountOfMoney(amount: 1000, currencyCode: "EUR")
        
        let card = Card(cardNumber: "123456789", paymentProductId: 1)
        cardSource = CardSource(card: card)
    }
    
    override func tearDown() {
        clientService = nil
        mockApiClient = nil
        mockCacheManager = nil
        sessionData = nil
        paymentContext = nil
        amountOfMoney = nil
        cardSource = nil
        super.tearDown()
    }
    
    // MARK: - IIN Details Tests
    
    func testGetIINDetailsReturnsCachedValue() {
        let expectation = self.expectation(description: "Returns cached IIN details")
        
        let iinDetails = try! FixtureLoader.loadJSON("iinDetailsResponse", as: IINDetailsResponse.self)
        mockCacheManager.cache["getIinDetails-42424242"] = iinDetails
        
        clientService.iinDetails(
            forBin: "42424242",
            forContext: paymentContext,
            success: { result in
                XCTAssertNotNil(result)
                XCTAssertEqual(result.paymentProductId, 1)
                XCTAssertEqual(result.countryCode, "BE")
                XCTAssertEqual(self.mockApiClient.postCallCount, 0, "Should not call API")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetIINDetailsCallsAPIWhenNotCached() {
        let expectation = self.expectation(description: "Calls API for IIN details")
        
        let iinDetails = try! FixtureLoader.loadJSON("iinDetailsResponse", as: IINDetailsResponse.self)
        mockApiClient.mockPostResponses["/services/getIINdetails"] = iinDetails
        
        clientService.iinDetails(
            forBin: "42424242",
            forContext: paymentContext,
            success: { result in
                XCTAssertNotNil(result)
                XCTAssertEqual(result.paymentProductId, 1)
                XCTAssertEqual(self.mockApiClient.postCallCount, 1, "Should call API once")
                
                let cached: IINDetailsResponse? = self.mockCacheManager.get(key: "getIinDetails-42424242")
                XCTAssertNotNil(cached, "Should cache the result")
                
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetIINDetailsWithoutContext() {
        let expectation = self.expectation(description: "IIN details without context")
        
        let iinDetails = try! FixtureLoader.loadJSON("iinDetailsResponse", as: IINDetailsResponse.self)
        mockApiClient.mockPostResponses["/services/getIINdetails"] = iinDetails
        
        clientService.iinDetails(
            forBin: "42424242",
            forContext: nil,
            success: { result in
                XCTAssertNotNil(result)
                XCTAssertEqual(result.paymentProductId, 1)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetIINDetailsReturnsErrorWhenResponseIsEmpty() {
        let expectation = self.expectation(description: "Returns error when response is nil")
        
        mockApiClient.mockPostResponses["/services/getIINdetails"] = nil
        
        clientService.iinDetails(
            forBin: "42424242",
            forContext: paymentContext,
            success: { _ in
                XCTFail("Should not succeed")
            },
            failure: { error in
                XCTAssertNotNil(error)
                XCTAssertTrue(error.message.contains("Could not fetch IinDetails."))
                expectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetIINDetailsHandlesNetworkError() {
        let expectation = self.expectation(description: "Handles network error")
        
        mockApiClient.shouldPostFail = true
        
        clientService.iinDetails(
            forBin: "42424242",
            forContext: paymentContext,
            success: { _ in
                XCTFail("Should not succeed")
            },
            failure: { error in
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
        
    func testGetCurrencyConversionQuoteReturnsCachedValue() {
        let expectation = self.expectation(description: "Returns cached currency conversion")
        
        let response = try! FixtureLoader.loadJSON("currencyConversionResponse", as: CurrencyConversionResponse.self)
        
        let cacheKey = "getCurrencyConversionQuote-1000-EUR-6789"
        mockCacheManager.cache[cacheKey] = response
        
        clientService.currencyConversionQuote(
            withAmountOfMoney: amountOfMoney,
            forCardSource: cardSource,
            success: { result in
                XCTAssertNotNil(result)
                XCTAssertEqual(result.dccSessionId, "5cd02469177743fb8a0b2c78937ee25f")
                XCTAssertEqual(result.result.result, .allowed)
                XCTAssertEqual(self.mockApiClient.postCallCount, 0, "Should not call API")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetCurrencyConversionQuoteCallsAPIWhenNotCached() {
        let expectation = self.expectation(description: "Calls API for currency conversion")
        
        let response = try! FixtureLoader.loadJSON("currencyConversionResponse", as: CurrencyConversionResponse.self)
        mockApiClient.mockPostResponses["/services/dccrate"] = response
        
        clientService.currencyConversionQuote(
            withAmountOfMoney: amountOfMoney,
            forCardSource: cardSource,
            success: { result in
                XCTAssertNotNil(result)
                XCTAssertEqual(result.dccSessionId, "5cd02469177743fb8a0b2c78937ee25f")
                XCTAssertEqual(result.proposal.baseAmount.amount, 1000)
                XCTAssertEqual(result.proposal.rate.exchangeRate, 1.57)
                XCTAssertEqual(self.mockApiClient.postCallCount, 1, "Should call API once")
                
                let cacheKey = "getCurrencyConversionQuote-1000-EUR-6789"
                let cached: CurrencyConversionResponse? = self.mockCacheManager.get(key: cacheKey)
                XCTAssertNotNil(cached, "Should cache the result")
                
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetCurrencyConversionQuoteWithToken() {
        let expectation = self.expectation(description: "Currency conversion with token")
        
        let tokenCardSource = CardSource(token: "token123")
        
        let response = try! FixtureLoader.loadJSON("currencyConversionResponse", as: CurrencyConversionResponse.self)
        mockApiClient.mockPostResponses["/services/dccrate"] = response
        
        clientService.currencyConversionQuote(
            withAmountOfMoney: amountOfMoney,
            forCardSource: tokenCardSource,
            success: { result in
                XCTAssertNotNil(result)
                XCTAssertEqual(result.dccSessionId, "5cd02469177743fb8a0b2c78937ee25f")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetCurrencyConversionQuoteReturnsErrorWhenResponseIsEmpty() {
        let expectation = self.expectation(description: "Returns error when response is nil")
        
        mockApiClient.mockPostResponses["/services/dccrate"] = nil
        
        clientService.currencyConversionQuote(
            withAmountOfMoney: amountOfMoney,
            forCardSource: cardSource,
            success: { _ in
                XCTFail("Should not succeed")
            },
            failure: { error in
                XCTAssertNotNil(error)
                XCTAssertTrue(error.message.contains("Could not fetch CurrencyConversionQuote."))
                expectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
        
    func testGetSurchargeCalculationReturnsCachedValue() {
        let expectation = self.expectation(description: "Returns cached surcharge calculation")
        
        let response = try! FixtureLoader.loadJSON("surchargeCalculationResponse", as: SurchargeCalculationResponse.self)
        
        let cacheKey = "getSurchargeCalculation-1000-EUR-6789"
        mockCacheManager.cache[cacheKey] = response
        
        clientService.surchargeCalculation(
            withAmountOfMoney: amountOfMoney,
            forCardSource: cardSource,
            success: { result in
                XCTAssertNotNil(result)
                XCTAssertEqual(result.surcharges.count, 1)
                XCTAssertEqual(result.surcharges[0].paymentProductId, 1)
                XCTAssertEqual(result.surcharges[0].result, .ok)
                XCTAssertEqual(self.mockApiClient.postCallCount, 0, "Should not call API")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetSurchargeCalculationCallsAPIWhenNotCached() {
        let expectation = self.expectation(description: "Calls API for surcharge calculation")
        
        let response = try! FixtureLoader.loadJSON("surchargeCalculationResponse", as: SurchargeCalculationResponse.self)
        mockApiClient.mockPostResponses["/services/surchargecalculation"] = response
        
        clientService.surchargeCalculation(
            withAmountOfMoney: amountOfMoney,
            forCardSource: cardSource,
            success: { result in
                XCTAssertNotNil(result)
                XCTAssertEqual(result.surcharges.count, 1)
                XCTAssertEqual(result.surcharges[0].totalAmount.amount, 1366)
                XCTAssertEqual(result.surcharges[0].surchargeAmount.amount, 366)
                XCTAssertEqual(self.mockApiClient.postCallCount, 1, "Should call API once")
                
                let cacheKey = "getSurchargeCalculation-1000-EUR-6789"
                let cached: SurchargeCalculationResponse? = self.mockCacheManager.get(key: cacheKey)
                XCTAssertNotNil(cached, "Should cache the result")
                
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testGetSurchargeCalculationReturnsErrorWhenResponseIsEmpty() {
        let expectation = self.expectation(description: "Returns error when response is nil")
        
        mockApiClient.mockPostResponses["/services/surchargecalculation"] = nil
        
        clientService.surchargeCalculation(
            withAmountOfMoney: amountOfMoney,
            forCardSource: cardSource,
            success: { _ in
                XCTFail("Should not succeed")
            },
            failure: { error in
                XCTAssertNotNil(error)
                XCTAssertTrue(error.message.contains("Could not fetch SurchargeCalculation."))
                expectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }

    func testGetIINDetailsReturnsNotEnoughDigitsWhenLessThan6Digits() {
        let expectation = self.expectation(description: "Returns not enough digits")
        
        clientService.iinDetails(
            forBin: "12345",
            forContext: paymentContext,
            success: { result in
                XCTAssertNotNil(result)
                XCTAssertEqual(result.status, .notEnoughDigits)
                XCTAssertEqual(self.mockApiClient.postCallCount, 0, "Should not call API")
                XCTAssertFalse(self.clientService.iinLookupPending, "Should not set pending flag")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }

    func testGetIINDetailsSetsLookupPendingFlagDuringAPICall() {
        let expectation = self.expectation(description: "Sets and clears lookup pending flag")
        
        let iinDetails = try! FixtureLoader.loadJSON("iinDetailsResponse", as: IINDetailsResponse.self)
        mockApiClient.mockPostResponses["/services/getIINdetails"] = iinDetails
        
        XCTAssertFalse(clientService.iinLookupPending, "Should start as false")
        
        clientService.iinDetails(
            forBin: "42424242",
            forContext: paymentContext,
            success: { result in
                XCTAssertNotNil(result)
                XCTAssertFalse(self.clientService.iinLookupPending, "Should clear flag on success")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }

    func testGetIINDetailsClearsLookupPendingFlagOnFailure() {
        let expectation = self.expectation(description: "Clears lookup pending flag on failure")
        
        mockApiClient.shouldPostFail = true
        
        XCTAssertFalse(clientService.iinLookupPending, "Should start as false")
        
        clientService.iinDetails(
            forBin: "42424242",
            forContext: paymentContext,
            success: { _ in
                XCTFail("Should not succeed")
            },
            failure: { error in
                XCTAssertFalse(self.clientService.iinLookupPending, "Should clear flag on failure")
                expectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }

    func testGetIINDetailsDoesNotSetPendingFlagWhenReturningCachedValue() {
        let expectation = self.expectation(description: "Does not set pending flag for cached value")
        
        let iinDetails = try! FixtureLoader.loadJSON("iinDetailsResponse", as: IINDetailsResponse.self)
        mockCacheManager.cache["getIinDetails-42424242"] = iinDetails
        
        XCTAssertFalse(clientService.iinLookupPending, "Should start as false")
        
        clientService.iinDetails(
            forBin: "42424242",
            forContext: paymentContext,
            success: { result in
                XCTAssertNotNil(result)
                XCTAssertFalse(self.clientService.iinLookupPending, "Should not set flag for cached result")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }
}
