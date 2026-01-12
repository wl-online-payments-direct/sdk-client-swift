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

public class EncryptionService: EncryptionServiceProtocol {
    private let apiClient: ApiClientProtocol
    private let cacheManager: CacheManagerProtocol
    private let sessionData: SessionData
    private let sdkConfiguration: SdkConfiguration?

    private let encryptor: Encryptor = Encryptor()
    private let joseEncryptor: JOSEEncryptor = JOSEEncryptor()
    private let util: MetadataUtil = MetadataUtil()

    internal init(
        apiClient: ApiClientProtocol,
        cacheManager: CacheManagerProtocol,
        sessionData: SessionData,
        sdkConfiguration: SdkConfiguration?
    ) {
        self.apiClient = apiClient
        self.cacheManager = cacheManager
        self.sessionData = sessionData
        self.sdkConfiguration = sdkConfiguration
    }

    public func getPublicKey(
        success: @escaping (_ publicKeyResponse: PublicKeyResponse) -> Void,
        failure: @escaping (_ error: SdkError) -> Void,
    ) {
        let cacheKey = "publicKey"

        if let cached: PublicKeyResponse = cacheManager.get(key: cacheKey) {
            success(cached)
            return
        }

        let strongSelf = self

        apiClient.get(
            path: "/crypto/publickey",
            parameters: nil,
            version: .v1,
            additionalAcceptableStatusCodes: nil,
            success: { (responseObject: PublicKeyResponse?, statusCode) in
                validateResponse(
                    responseObject,
                    statusCode: statusCode,
                    message: "Could not fetch PublicKey.",
                    success: { validatedPublicKey in
                        strongSelf.cacheManager.set(key: cacheKey, value: validatedPublicKey)

                        success(validatedPublicKey)
                    },
                    failure: failure
                )
            },
            failure: { error in
                failure(error)
            },
        )
    }

    public func encryptPaymentRequest(
        _ paymentRequest: PaymentRequest,
        success: @escaping (_ encryptedRequest: EncryptedRequest) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    ) {
        do {
            let validationResult = try paymentRequest.validate()
            if !validationResult.isValid {
                let error = InvalidArgumentError(
                    message: "The payment request is not valid.",
                    data: validationResult.raw
                )
                failure(error)
                return
            }

            guard let paymentRequestJSON = preparePaymentRequestJSON(paymentRequest: paymentRequest) else {
                let error = EncryptionError(message: "Failed to serialize payment request to JSON")
                failure(error)
                return
            }
            encryptJSON(paymentRequestJSON, success: success, failure: failure)
        } catch {
            let encryptionError = InvalidArgumentError(
                message: "Failed to validate payment request: \(error.localizedDescription)"
            )
            failure(encryptionError)
        }
    }

    public func encryptTokenRequest(
        _ tokenRequest: CreditCardTokenRequest,
        success: @escaping (_ encryptedRequest: EncryptedRequest) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    ) {
        guard let tokenRequestJSON = prepareTokenRequestJSON(tokenRequest: tokenRequest) else {
            let error = EncryptionError(message: "Failed to serialize token request to JSON")
            failure(error)
            return
        }
        encryptJSON(tokenRequestJSON, success: success, failure: failure)
    }

    // MARK: - Private Methods

    private func encryptJSON(
        _ jsonString: String,
        success: @escaping (_ encryptedRequest: EncryptedRequest) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    ) {
        getPublicKey(
            success: { [weak self] publicKeyResponse in
                guard let self = self else { return }

                do {
                    // Decode and strip public key
                    let publicKeyAsData = publicKeyResponse.publicKey.decode()
                    let strippedPublicKeyAsData = try self.encryptor.stripPublicKey(data: publicKeyAsData)

                    let tag = "globalcollect-sdk-public-key-swift"

                    // Store the key
                    self.encryptor.deleteRSAKey(withTag: tag)
                    self.encryptor.storePublicKey(publicKey: strippedPublicKeyAsData, tag: tag)

                    guard let publicKey = self.encryptor.RSAKey(withTag: tag) else {
                        let error = EncryptionError(message: "RSA key not found after storage")
                        failure(error)
                        return
                    }

                    // Encrypt the JSON
                    let encryptedCustomerInput = try self.joseEncryptor.encryptToCompactSerialization(
                        JSON: jsonString,
                        withPublicKey: publicKey,
                        keyId: publicKeyResponse.keyId
                    )

                    let encodedClientMetaInfo = self.util.base64EncodedClientMetaInfo(
                        withAppIdentifier: self.sdkConfiguration?.appIdentifier ?? "",
                        addedData: nil,
                        sdkIdentifier: SdkConstants.kSDKIdentifier
                    )

                    // Create prepared request
                    let preparedRequest = EncryptedRequest(
                        encryptedCustomerInput: encryptedCustomerInput,
                        encodedClientMetaInfo: encodedClientMetaInfo ?? ""
                    )

                    success(preparedRequest)

                } catch {
                    let encryptionError = EncryptionError(
                        message: "Encryption failed: \(error.localizedDescription)"
                    )
                    failure(encryptionError)
                }
            },
            failure: failure
        )
    }

    private func preparePaymentRequestJSON(paymentRequest: PaymentRequest) -> String? {
        var jsonDict: [String: Any] = [
            "clientSessionId": sessionData.clientSessionId,
            "nonce": encryptor.generateUUID(),
        ]

        // Add payment product ID
        jsonDict["paymentProductId"] = paymentRequest.paymentProduct.id

        // Add account on file ID if present
        if let accountOnFile = paymentRequest.accountOnFile {
            jsonDict["accountOnFileId"] = accountOnFile.id
        }

        // Add tokenize flag if true
        if paymentRequest.tokenize {
            jsonDict["tokenize"] = true
        }

        // Add payment values
        let fieldValues = paymentRequest.values()
        if !fieldValues.isEmpty {
            jsonDict["paymentValues"] = keyValuePairs(from: fieldValues)
        }

        // Serialize to JSON string
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []),
            let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            return nil
        }

        return jsonString
    }

    private func prepareTokenRequestJSON(tokenRequest: CreditCardTokenRequest) -> String? {
        var jsonDict: [String: Any] = [
            "clientSessionId": sessionData.clientSessionId,
            "nonce": encryptor.generateUUID(),
        ]

        // Add payment product ID
        if let productId = tokenRequest.paymentProductId?.intValue {
            jsonDict["paymentProductId"] = productId
        }

        let fieldValues = tokenRequest.getValues()

        if !fieldValues.isEmpty {
            jsonDict["paymentValues"] = keyValuePairs(from: fieldValues)
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []),
            let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            return nil
        }

        return jsonString
    }

    private func keyValuePairs(from dictionary: [String: String]) -> [[String: String]] {
        return dictionary.map { key, value in
            ["key": key, "value": value]
        }
    }
}
