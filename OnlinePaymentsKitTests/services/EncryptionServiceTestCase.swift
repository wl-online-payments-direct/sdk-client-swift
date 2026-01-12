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

class EncryptionServiceTests: XCTestCase {
    var service: EncryptionService!
    var sessionData: SessionData!
    var configuration: SdkConfiguration!
    var mockApiClient: ApiClientMock!
    var mockCacheManager: CacheManagerMock!
    
    override func setUp() {
        super.setUp()
        
        sessionData = SessionData(
            clientSessionId: "test-session-id",
            customerId: "test-customer-id",
            clientApiUrl: "https://test-client-api",
            assetUrl: "test-url"
        )
        
        configuration = SdkConfiguration(
            appIdentifier: "test-appIdentifier"
        )
        
        mockApiClient = ApiClientMock()
        mockCacheManager = CacheManagerMock()
        
        service = EncryptionService(
            apiClient: mockApiClient,
            cacheManager: mockCacheManager,
            sessionData: sessionData,
            sdkConfiguration: configuration
        )
    }
    
    override func tearDown() {
        service = nil
        sessionData = nil
        configuration = nil
        mockApiClient = nil
        mockCacheManager = nil
        super.tearDown()
    }
        
    func testEncryptPaymentRequestReturnsEncryptedFields() {
        let paymentProduct = PaymentProductFactory().createPaymentProduct(from: try! FixtureLoader.loadJSON("cardPaymentProduct", as: PaymentProductDto.self))
        let request = PaymentRequest(paymentProduct: paymentProduct)
        try! request.setValue(id: "cvv", value: "123")
        try! request.setValue(id: "expiryDate", value: "12/2026")
        try! request.setValue(id: "cardNumber", value: "4242424242424242")
        
        setupMockApiClientForPublicKey()
        
        let expectation = self.expectation(description: "Encrypt payment request")
        
        service.encryptPaymentRequest(
            request,
            success: { encryptedRequest in
                XCTAssertNotNil(encryptedRequest.encryptedCustomerInput)
                XCTAssertFalse(encryptedRequest.encryptedCustomerInput.isEmpty)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
            }
        )
        
        waitForExpectations(timeout: 5.0)
    }
    
    func testEncryptPaymentRequestFailsWithInvalidRequest() {
        let paymentProduct = PaymentProductFactory().createPaymentProduct(from: try! FixtureLoader.loadJSON("cardPaymentProduct", as: PaymentProductDto.self))
        let request = PaymentRequest(paymentProduct: paymentProduct)
        
        let expectation = self.expectation(description: "Encrypt payment request fails")
        
        service.encryptPaymentRequest(
            request,
            success: { _ in
                XCTFail("Should not succeed with invalid request")
            },
            failure: { error in
                XCTAssertTrue(error is InvalidArgumentError)
                if let invalidError = error as? InvalidArgumentError {
                    XCTAssertEqual(invalidError.message, "The payment request is not valid.")
                }
                expectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 5.0)
    }
    
    func testEncryptPaymentRequestFailsWhenPublicKeyFetchFails() {
        let paymentProduct = PaymentProductFactory().createPaymentProduct(from: try! FixtureLoader.loadJSON("cardPaymentProduct", as: PaymentProductDto.self))
        let request = PaymentRequest(paymentProduct: paymentProduct)
        try! request.setValue(id: "cvv", value: "123")
        try! request.setValue(id: "expiryDate", value: "12/2026")
        try! request.setValue(id: "cardNumber", value: "4242424242424242")
        
        mockApiClient.shouldGetFail = true
        mockApiClient.mockGetError = ResponseError(
            httpStatusCode: 500,
            message: "Server error",
            data: nil
        )
        
        let expectation = self.expectation(description: "Encrypt payment request fails")
        
        service.encryptPaymentRequest(
            request,
            success: { _ in
                XCTFail("Should not succeed when public key fetch fails")
            },
            failure: { error in
                XCTAssertTrue(error is ResponseError)
                if let responseError = error as? ResponseError {
                    XCTAssertEqual(responseError.httpStatusCode, 500)
                    XCTAssertEqual(responseError.message, "Server error")
                }
                expectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 5.0)
    }
    
    func testEncryptPaymentRequestFailsWithCommunicationError() {
        let paymentProduct = PaymentProductFactory().createPaymentProduct(from: try! FixtureLoader.loadJSON("cardPaymentProduct", as: PaymentProductDto.self))
        let request = PaymentRequest(paymentProduct: paymentProduct)
        try! request.setValue(id: "cvv", value: "123")
        try! request.setValue(id: "expiryDate", value: "12/2026")
        try! request.setValue(id: "cardNumber", value: "4242424242424242")
        
        mockApiClient.shouldGetFailWithCommunicationError = true
        
        let expectation = self.expectation(description: "Encrypt payment request fails with communication error")
        
        service.encryptPaymentRequest(
            request,
            success: { _ in
                XCTFail("Should not succeed with communication error")
            },
            failure: { error in
                XCTAssertTrue(error is CommunicationError)
                if let commError = error as? CommunicationError {
                    XCTAssertEqual(commError.message, "Mock communication error")
                }
                expectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 5.0)
    }
        
    func testEncryptTokenRequestReturnsEncryptedFields() {
        let token = CreditCardTokenRequest()
        token.securityCode = "123"
        token.cardNumber = "424242424242"
        token.paymentProductId = NSNumber(value: 1)
        
        setupMockApiClientForPublicKey()
        
        let expectation = self.expectation(description: "Encrypt token request")
        
        service.encryptTokenRequest(
            token,
            success: { encryptedRequest in
                XCTAssertNotNil(encryptedRequest.encryptedCustomerInput)
                XCTAssertFalse(encryptedRequest.encryptedCustomerInput.isEmpty)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
            }
        )
        
        waitForExpectations(timeout: 5.0)
    }
    
    func testEncryptTokenRequestFailsWhenPublicKeyFetchFails() {
        let token = CreditCardTokenRequest()
        token.securityCode = "123"
        token.cardNumber = "424242424242"
        token.paymentProductId = NSNumber(value: 1)
        
        mockApiClient.shouldGetFail = true
        mockApiClient.mockGetError = ResponseError(
            httpStatusCode: 404,
            message: "Not found",
            data: nil
        )
        
        let expectation = self.expectation(description: "Encrypt token request fails")
        
        service.encryptTokenRequest(
            token,
            success: { _ in
                XCTFail("Should not succeed when public key fetch fails")
            },
            failure: { error in
                XCTAssertTrue(error is ResponseError)
                if let responseError = error as? ResponseError {
                    XCTAssertEqual(responseError.httpStatusCode, 404)
                    XCTAssertEqual(responseError.message, "Not found")
                }
                expectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 5.0)
    }
    
    func testEncryptTokenRequestFailsWithCommunicationError() {
        let token = CreditCardTokenRequest()
        token.securityCode = "123"
        token.cardNumber = "424242424242"
        token.paymentProductId = NSNumber(value: 1)
        
        mockApiClient.shouldGetFailWithCommunicationError = true
        
        let expectation = self.expectation(description: "Encrypt token request fails with communication error")
        
        service.encryptTokenRequest(
            token,
            success: { _ in
                XCTFail("Should not succeed with communication error")
            },
            failure: { error in
                XCTAssertTrue(error is CommunicationError)
                if let commError = error as? CommunicationError {
                    XCTAssertEqual(commError.message, "Mock communication error")
                }
                expectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 5.0)
    }
        
    func testGetPublicKeyReturnsFromCacheWhenAvailable() {
        let cachedPublicKey = try! FixtureLoader.loadJSON("publicKeyResponse", as: PublicKeyResponse.self)
        mockCacheManager.cache["publicKey"] = cachedPublicKey
        
        let expectation = self.expectation(description: "Get public key from cache")
        
        service.getPublicKey(
            success: { publicKeyResponse in
                XCTAssertEqual(self.mockCacheManager.getCalledWithKey, "publicKey")
                XCTAssertEqual(self.mockApiClient.getCallCount, 0)
                XCTAssertEqual(publicKeyResponse.keyId, cachedPublicKey.keyId)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
            }
        )
        
        waitForExpectations(timeout: 5.0)
    }
    
    func testGetPublicKeyFetchesFromApiWhenNotCached() {
        let publicKeyResponse = try! FixtureLoader.loadJSON("publicKeyResponse", as: PublicKeyResponse.self)
        mockApiClient.mockGetResponses["/crypto/publickey"] = publicKeyResponse
        
        let expectation = self.expectation(description: "Get public key from API")
        
        service.getPublicKey(
            success: { response in
                XCTAssertEqual(self.mockApiClient.lastGetPath, "/crypto/publickey")
                XCTAssertEqual(self.mockApiClient.getCallCount, 1)
                XCTAssertEqual(self.mockCacheManager.setCalledWithKey, "publicKey")
                XCTAssertNotNil(self.mockCacheManager.setCalledWithValue)
                XCTAssertEqual(response.keyId, publicKeyResponse.keyId)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
            }
        )
        
        waitForExpectations(timeout: 5.0)
    }
    
    func testGetPublicKeyFailsWithResponseError() {
        mockApiClient.shouldGetFail = true
        mockApiClient.mockGetError = ResponseError(
            httpStatusCode: 503,
            message: "Service unavailable",
            data: nil
        )
        
        let expectation = self.expectation(description: "Get public key fails")
        
        service.getPublicKey(
            success: { _ in
                XCTFail("Should not succeed when API fails")
            },
            failure: { error in
                XCTAssertTrue(error is ResponseError)
                if let responseError = error as? ResponseError {
                    XCTAssertEqual(responseError.httpStatusCode, 503)
                    XCTAssertEqual(responseError.message, "Service unavailable")
                }
                expectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 5.0)
    }
    
    func testGetPublicKeyFailsWithCommunicationError() {
        mockApiClient.shouldGetFailWithCommunicationError = true
        
        let expectation = self.expectation(description: "Get public key fails with communication error")
        
        service.getPublicKey(
            success: { _ in
                XCTFail("Should not succeed with communication error")
            },
            failure: { error in
                XCTAssertTrue(error is CommunicationError)
                if let commError = error as? CommunicationError {
                    XCTAssertEqual(commError.message, "Mock communication error")
                }
                expectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 5.0)
    }
        
    private func setupMockApiClientForPublicKey() {
        let publicKey = try! FixtureLoader.loadJSON("publicKeyResponse", as: PublicKeyResponse.self)
        mockApiClient.mockGetResponses["/crypto/publickey"] = publicKey
    }
}
