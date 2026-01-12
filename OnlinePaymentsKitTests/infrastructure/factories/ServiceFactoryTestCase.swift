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

class ServiceFactoryTests: XCTestCase {

    var mockSessionData: SessionData!
    var mockConfiguration: SdkConfiguration!

    override func setUp() {
        super.setUp()
        mockSessionData = SessionData(
            clientSessionId: "test-session-id",
            customerId: "test-customer-id",
            clientApiUrl: "https://api.test.com",
            assetUrl: "https://assets.test.com"
        )

        mockConfiguration = SdkConfiguration(
            appIdentifier: "test app",
            loggingEnabled: false,
        )
    }

    override func tearDown() {
        mockSessionData = nil
        mockConfiguration = nil
        super.tearDown()
    }

    // MARK: - Default Instance Creation Tests

    func testCreatesAllDefaultInstances() {
        // Given
        let props = ServiceFactoryProps(
            sessionData: mockSessionData,
            configuration: mockConfiguration
        )

        // When
        let serviceFactory = ServiceFactory(configuration: props)

        // Then
        XCTAssertNotNil(serviceFactory.getApiClient())
        XCTAssertTrue(serviceFactory.getApiClient() is ApiClient)

        XCTAssertNotNil(serviceFactory.getCacheManager())
        XCTAssertTrue(serviceFactory.getCacheManager() is CacheManager)

        XCTAssertNotNil(serviceFactory.getEncryptionService())
        XCTAssertTrue(serviceFactory.getEncryptionService() is EncryptionService)

        XCTAssertNotNil(serviceFactory.getPaymentProductService())
        XCTAssertTrue(serviceFactory.getPaymentProductService() is PaymentProductService)

        XCTAssertNotNil(serviceFactory.getClientService())
        XCTAssertTrue(serviceFactory.getClientService() is ClientService)
    }

    func testCreatesDefaultInstancesWithoutConfiguration() {
        // Given
        let props = ServiceFactoryProps(
            sessionData: mockSessionData,
            configuration: nil
        )

        // When
        let serviceFactory = ServiceFactory(configuration: props)

        // Then
        XCTAssertNotNil(serviceFactory.getApiClient())
        XCTAssertNotNil(serviceFactory.getCacheManager())
        XCTAssertNotNil(serviceFactory.getEncryptionService())
        XCTAssertNotNil(serviceFactory.getPaymentProductService())
        XCTAssertNotNil(serviceFactory.getClientService())
    }

    // MARK: - Custom Service Injection Tests

    func testReturnsApiClientIfProvidedInConstructor() {
        // Given
        let mockApiClient = ApiClientMock()
        let props = ServiceFactoryProps(
            sessionData: mockSessionData,
            configuration: mockConfiguration,
            apiClient: mockApiClient
        )

        // When
        let serviceFactory = ServiceFactory(configuration: props)

        // Then
        XCTAssertTrue(serviceFactory.getApiClient() is ApiClientMock)
        XCTAssertFalse(serviceFactory.getApiClient() is ApiClient)

        // Verify it's the same instance using ObjectIdentifier
        XCTAssertEqual(
            ObjectIdentifier(serviceFactory.getApiClient() as AnyObject),
            ObjectIdentifier(mockApiClient as AnyObject)
        )
    }

    func testReturnsCacheManagerIfProvidedInConstructor() {
        // Given
        let mockCacheManager = CacheManagerMock()
        let props = ServiceFactoryProps(
            sessionData: mockSessionData,
            configuration: mockConfiguration,
            cacheManager: mockCacheManager
        )

        // When
        let serviceFactory = ServiceFactory(configuration: props)

        // Then
        XCTAssertTrue(serviceFactory.getCacheManager() is CacheManagerMock)
        XCTAssertFalse(serviceFactory.getCacheManager() is CacheManager)

        // Verify it's the same instance
        XCTAssertEqual(
            ObjectIdentifier(serviceFactory.getCacheManager() as AnyObject),
            ObjectIdentifier(mockCacheManager as AnyObject)
        )
    }

    func testReturnsEncryptionServiceIfProvidedInConstructor() {
        // Given
        let mockEncryptionService = MockEncryptionService()
        let props = ServiceFactoryProps(
            sessionData: mockSessionData,
            configuration: mockConfiguration,
            encryptionService: mockEncryptionService
        )

        // When
        let serviceFactory = ServiceFactory(configuration: props)

        // Then
        XCTAssertTrue(serviceFactory.getEncryptionService() is MockEncryptionService)
        XCTAssertFalse(serviceFactory.getEncryptionService() is EncryptionService)

        // Verify it's the same instance
        XCTAssertEqual(
            ObjectIdentifier(serviceFactory.getEncryptionService() as AnyObject),
            ObjectIdentifier(mockEncryptionService as AnyObject)
        )
    }

    func testReturnsPaymentProductServiceIfProvidedInConstructor() {
        // Given
        let mockPaymentProductService = MockPaymentProductService()
        let props = ServiceFactoryProps(
            sessionData: mockSessionData,
            configuration: mockConfiguration,
            paymentProductService: mockPaymentProductService
        )

        // When
        let serviceFactory = ServiceFactory(configuration: props)

        // Then
        XCTAssertTrue(serviceFactory.getPaymentProductService() is MockPaymentProductService)
        XCTAssertFalse(serviceFactory.getPaymentProductService() is PaymentProductService)

        // Verify it's the same instance
        XCTAssertEqual(
            ObjectIdentifier(serviceFactory.getPaymentProductService() as AnyObject),
            ObjectIdentifier(mockPaymentProductService as AnyObject)
        )
    }

    func testReturnsClientServiceIfProvidedInConstructor() {
        // Given
        let mockClientService = MockClientService()
        let props = ServiceFactoryProps(
            sessionData: mockSessionData,
            configuration: mockConfiguration,
            clientService: mockClientService
        )

        // When
        let serviceFactory = ServiceFactory(configuration: props)

        // Then
        XCTAssertTrue(serviceFactory.getClientService() is MockClientService)
        XCTAssertFalse(serviceFactory.getClientService() is ClientService)

        // Verify it's the same instance
        XCTAssertEqual(
            ObjectIdentifier(serviceFactory.getClientService() as AnyObject),
            ObjectIdentifier(mockClientService as AnyObject)
        )
    }

    // MARK: - Mixed Injection Tests

    func testMixesCustomAndDefaultServices() {
        // Given
        let mockApiClient = ApiClientMock()
        let mockClientService = MockClientService()
        let props = ServiceFactoryProps(
            sessionData: mockSessionData,
            configuration: mockConfiguration,
            apiClient: mockApiClient,
            clientService: mockClientService
        )

        // When
        let serviceFactory = ServiceFactory(configuration: props)

        // Then
        // Custom services
        XCTAssertTrue(serviceFactory.getApiClient() is ApiClientMock)
        XCTAssertTrue(serviceFactory.getClientService() is MockClientService)

        // Verify they're the same instances
        XCTAssertEqual(
            ObjectIdentifier(serviceFactory.getApiClient() as AnyObject),
            ObjectIdentifier(mockApiClient as AnyObject)
        )
        XCTAssertEqual(
            ObjectIdentifier(serviceFactory.getClientService() as AnyObject),
            ObjectIdentifier(mockClientService as AnyObject)
        )

        // Default services
        XCTAssertTrue(serviceFactory.getCacheManager() is CacheManager)
        XCTAssertTrue(serviceFactory.getEncryptionService() is EncryptionService)
        XCTAssertTrue(serviceFactory.getPaymentProductService() is PaymentProductService)
    }

    // MARK: - Service Singleton Tests

    func testReturnsConsistentInstances() {
        // Given
        let props = ServiceFactoryProps(
            sessionData: mockSessionData,
            configuration: mockConfiguration
        )
        let serviceFactory = ServiceFactory(configuration: props)

        // When & Then - ApiClient
        let apiClient1 = serviceFactory.getApiClient()
        let apiClient2 = serviceFactory.getApiClient()
        XCTAssertEqual(
            ObjectIdentifier(apiClient1 as AnyObject),
            ObjectIdentifier(apiClient2 as AnyObject),
            "ApiClient should return the same instance"
        )

        // CacheManager
        let cacheManager1 = serviceFactory.getCacheManager()
        let cacheManager2 = serviceFactory.getCacheManager()
        XCTAssertEqual(
            ObjectIdentifier(cacheManager1 as AnyObject),
            ObjectIdentifier(cacheManager2 as AnyObject),
            "CacheManager should return the same instance"
        )

        // EncryptionService
        let encryptionService1 = serviceFactory.getEncryptionService()
        let encryptionService2 = serviceFactory.getEncryptionService()
        XCTAssertEqual(
            ObjectIdentifier(encryptionService1 as AnyObject),
            ObjectIdentifier(encryptionService2 as AnyObject),
            "EncryptionService should return the same instance"
        )

        // PaymentProductService
        let paymentService1 = serviceFactory.getPaymentProductService()
        let paymentService2 = serviceFactory.getPaymentProductService()
        XCTAssertEqual(
            ObjectIdentifier(paymentService1 as AnyObject),
            ObjectIdentifier(paymentService2 as AnyObject),
            "PaymentProductService should return the same instance"
        )

        // ClientService
        let clientService1 = serviceFactory.getClientService()
        let clientService2 = serviceFactory.getClientService()
        XCTAssertEqual(
            ObjectIdentifier(clientService1 as AnyObject),
            ObjectIdentifier(clientService2 as AnyObject),
            "ClientService should return the same instance"
        )
    }
}
