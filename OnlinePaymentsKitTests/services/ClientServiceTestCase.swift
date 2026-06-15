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
                XCTAssertEqual(result.paymentProductId, 1)
                XCTAssertEqual(self.mockApiClient.lastPostPath, "/services/getIINdetails")
                XCTAssertEqual(self.mockApiClient.postCallCount, 1, "Should call API once")
                XCTAssertEqual(self.mockApiClient.lastPostAdditionalStatusCodes, IndexSet(integer: 404))
                
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
        
        // No response registered in mockPostResponses — mock returns nil by default
        clientService.iinDetails(
            forBin: "42424242",
            forContext: paymentContext,
            success: { _ in
                XCTFail("Should not succeed")
            },
            failure: { error in
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
                XCTAssertEqual(result.dccSessionId, "5cd02469177743fb8a0b2c78937ee25f")
                XCTAssertEqual(result.proposal.baseAmount.amount, 1000)
                XCTAssertEqual(result.proposal.rate.exchangeRate, 1.57)

                XCTAssertEqual(self.mockApiClient.lastPostPath, "/services/dccrate")
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
                XCTAssertEqual(result.dccSessionId, "5cd02469177743fb8a0b2c78937ee25f")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }

    func testGetCurrencyConversionQuoteWithCardUsesCardSourceInRequest() {
        let expectation = self.expectation(description: "Card source shape in DCC request body")

        let card = Card(cardNumber: "4242424242424242", paymentProductId: 1)
        let cardCardSource = CardSource(card: card)

        let response = try! FixtureLoader.loadJSON("currencyConversionResponse", as: CurrencyConversionResponse.self)
        mockApiClient.mockPostResponses["/services/dccrate"] = response

        clientService.currencyConversionQuote(
            withAmountOfMoney: amountOfMoney,
            forCardSource: cardCardSource,
            success: { _ in
                let cardSource = self.mockApiClient.lastPostParameters?["cardSource"] as? [String: Any]
                XCTAssertNotNil(cardSource)
                let cardDict = cardSource?["card"] as? [String: Any]
                XCTAssertNotNil(cardDict, "cardSource.card should be present for a card-based request")
                XCTAssertEqual(cardDict?["cardNumber"] as? String, "4242424242424242")
                XCTAssertNil(cardSource?["token"], "cardSource.token should be nil for a card-based request")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error.message)")
            }
        )

        waitForExpectations(timeout: 2.0)
    }
    
    func testGetCurrencyConversionQuoteReturnsErrorWhenResponseIsEmpty() {
        let expectation = self.expectation(description: "Returns error when response is nil")
        
        // No response registered in mockPostResponses — mock returns nil by default
        clientService.currencyConversionQuote(
            withAmountOfMoney: amountOfMoney,
            forCardSource: cardSource,
            success: { _ in
                XCTFail("Should not succeed")
            },
            failure: { error in
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
                XCTAssertEqual(result.surcharges.count, 1)
                XCTAssertEqual(result.surcharges[0].totalAmount.amount, 1366)
                XCTAssertEqual(result.surcharges[0].surchargeAmount.amount, 366)
                XCTAssertEqual(self.mockApiClient.lastPostPath, "/services/surchargecalculation")
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
        
        // No response registered in mockPostResponses — mock returns nil by default
        clientService.surchargeCalculation(
            withAmountOfMoney: amountOfMoney,
            forCardSource: cardSource,
            success: { _ in
                XCTFail("Should not succeed")
            },
            failure: { error in
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
                XCTAssertFalse(self.clientService.iinLookupPending, "Should not set flag for cached result")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail")
            }
        )
        
        waitForExpectations(timeout: 2.0)
    }

    func testGetIINDetailsFormatsPartialCardNumberBeforeRequest() {
        let expectation = self.expectation(description: "Partial card number is formatted before request")

        let iinDetails = try! FixtureLoader.loadJSON("iinDetailsResponse", as: IINDetailsResponse.self)
        mockApiClient.mockPostResponses["/services/getIINdetails"] = iinDetails

        clientService.iinDetails(
            forBin: "1234567890",
            forContext: paymentContext,
            success: { _ in
                let bin = self.mockApiClient.lastPostParameters?["bin"] as? String
                XCTAssertEqual(bin, "12345678")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error.message)")
            }
        )

        waitForExpectations(timeout: 2.0)
    }

    func testGetIINDetailsMapsExistingButNotAllowedStatus() {
        let expectation = self.expectation(description: "Maps isAllowedInContext=false to existingButNotAllowed")

        let json = """
        {
            "countryCode": "NL",
            "paymentProductId": 1,
            "cardType": "Credit",
            "isAllowedInContext": false
        }
        """
        let notAllowedResponse = try! JSONDecoder().decode(
            IINDetailsResponse.self,
            from: json.data(using: .utf8)!
        )
        mockApiClient.mockPostResponses["/services/getIINdetails"] = notAllowedResponse

        clientService.iinDetails(
            forBin: "424242",
            forContext: paymentContext,
            success: { result in
                XCTAssertEqual(result.status, .existingButNotAllowed)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error.message)")
            }
        )

        waitForExpectations(timeout: 2.0)
    }

    func testGetSurchargeCalculationWithTokenUsesTokenSourceInRequest() {
        let expectation = self.expectation(description: "Token source is used in surcharge request body")

        let response = try! FixtureLoader.loadJSON(
            "surchargeCalculationResponse",
            as: SurchargeCalculationResponse.self
        )
        mockApiClient.mockPostResponses["/services/surchargecalculation"] = response

        let tokenCardSource = CardSource(token: "test-token-123")

        clientService.surchargeCalculation(
            withAmountOfMoney: amountOfMoney,
            forCardSource: tokenCardSource,
            success: { _ in
                let cardSource = self.mockApiClient.lastPostParameters?["cardSource"] as? [String: Any]
                XCTAssertNotNil(cardSource)
                XCTAssertEqual(cardSource?["token"] as? String, "test-token-123")
                XCTAssertNil(cardSource?["card"])
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error.message)")
            }
        )

        waitForExpectations(timeout: 2.0)
    }

    func testValidateResponseWithNilDataThrowsResponseError() {
        var failureCalled = false
        var receivedError: SdkError?

        validateResponse(
            nil as String?,
            statusCode: 200,
            message: "Test error message",
            success: { _ in
                XCTFail("Should not succeed when response data is nil")
            },
            failure: { error in
                failureCalled = true
                receivedError = error
            }
        )

        XCTAssertTrue(failureCalled)
        XCTAssertTrue(receivedError is ResponseError)
        if let responseError = receivedError as? ResponseError {
            XCTAssertEqual(responseError.httpStatusCode, 200)
            XCTAssertEqual(responseError.message, "Test error message")
        }
    }
}
