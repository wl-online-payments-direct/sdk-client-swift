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

public class EncryptionError: SdkError {
    public init(message: String, metadata: SdkErrorMetadata? = nil) {
        super.init(
            message: message,
            code: .encryptionError,
            metadata: metadata
        )
    }
}

extension EncryptionError {
    static let algorithmNotSupported = "Algorithm not supported for the provided key"
    static let encryptionFailed = "Encryption failed"
    static let decryptionFailed = "Decryption failed"
    static let rsaKeyNotFound = "RSA key not found after storage"
    static let badPublicKeyFormat = "The provided public key data has an unexpected format"
    static let aesEncryptionFailed = "AES encryption failed"
    static let aesDecryptionFailed = "AES decryption failed"
    static let hmacGenerationFailed = "HMAC generation failed"
}
