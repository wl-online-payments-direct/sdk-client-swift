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

internal protocol ServiceFactoryProtocol {
    func getApiClient() -> ApiClientProtocol
    func getCacheManager() -> CacheManagerProtocol
    func getEncryptionService() -> EncryptionServiceProtocol
    func getPaymentProductService() -> PaymentProductServiceProtocol
    func getClientService() -> ClientServiceProtocol
}

internal struct ServiceFactoryProps {
    let sessionData: SessionData
    let configuration: SdkConfiguration?
    let apiClient: ApiClientProtocol?
    let cacheManager: CacheManagerProtocol?
    let encryptionService: EncryptionServiceProtocol?
    let paymentProductService: PaymentProductServiceProtocol?
    let clientService: ClientServiceProtocol?

    internal init(
        sessionData: SessionData,
        configuration: SdkConfiguration? = nil,
        apiClient: ApiClientProtocol? = nil,
        cacheManager: CacheManagerProtocol? = nil,
        encryptionService: EncryptionServiceProtocol? = nil,
        paymentProductService: PaymentProductServiceProtocol? = nil,
        clientService: ClientServiceProtocol? = nil
    ) {
        self.sessionData = sessionData
        self.configuration = configuration
        self.apiClient = apiClient
        self.cacheManager = cacheManager
        self.encryptionService = encryptionService
        self.paymentProductService = paymentProductService
        self.clientService = clientService
    }
}
