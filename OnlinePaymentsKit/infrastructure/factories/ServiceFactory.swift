/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation

internal class ServiceFactory: ServiceFactoryProtocol {

    private let apiClient: ApiClientProtocol
    private let cacheManager: CacheManagerProtocol
    private let encryptionService: EncryptionServiceProtocol
    private let paymentProductService: PaymentProductServiceProtocol
    private let clientService: ClientServiceProtocol

    internal init(configuration: ServiceFactoryProps) {
        self.apiClient =
            configuration.apiClient
            ?? ApiClient(
                sessionData: configuration.sessionData,
                loggingEnabled: configuration.configuration?.loggingEnabled ?? false
            )

        self.cacheManager = configuration.cacheManager ?? CacheManager()

        self.encryptionService =
            configuration.encryptionService
            ?? EncryptionService(
                apiClient: self.apiClient,
                cacheManager: self.cacheManager,
                sessionData: configuration.sessionData,
                sdkConfiguration: configuration.configuration
            )

        self.paymentProductService =
            configuration.paymentProductService
            ?? PaymentProductService(
                apiClient: self.apiClient,
                cacheManager: self.cacheManager,
                sessionData: configuration.sessionData
            )

        self.clientService =
            configuration.clientService
            ?? ClientService(
                apiClient: self.apiClient,
                cacheManager: self.cacheManager,
                sessionData: configuration.sessionData
            )
    }

    internal convenience init(
        sessionData: SessionData,
        configuration: SdkConfiguration?
    ) {
        self.init(
            configuration: ServiceFactoryProps(
                sessionData: sessionData,
                configuration: configuration,
                apiClient: nil,
                cacheManager: nil,
                encryptionService: nil,
                paymentProductService: nil,
                clientService: nil
            )
        )
    }

    internal func getApiClient() -> ApiClientProtocol {
        return apiClient
    }

    internal func getCacheManager() -> CacheManagerProtocol {
        return cacheManager
    }

    internal func getEncryptionService() -> EncryptionServiceProtocol {
        return encryptionService
    }

    internal func getPaymentProductService() -> PaymentProductServiceProtocol {
        return paymentProductService
    }

    internal func getClientService() -> ClientServiceProtocol {
        return clientService
    }
}
