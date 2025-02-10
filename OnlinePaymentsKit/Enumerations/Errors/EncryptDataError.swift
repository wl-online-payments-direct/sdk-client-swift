//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 28/09/2023
// Copyright © 2025 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPEncryptDataError)
public enum EncryptDataError: Int, Error {
    case publicKeyDecodeError
    case rsaKeyNotFound
    case algorithmNotSupported
    case hmacGenerationFailed
    case badPublicKeyFormat
}

extension EncryptDataError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .publicKeyDecodeError:
            return "Failed to decode Public key."
        case .rsaKeyNotFound:
            return "Failed to find RSA key."
        case .algorithmNotSupported:
            return "Encryption alghoritm is not supported."
        case .badPublicKeyFormat:
            return "The public key is not in the correct format."
        case .hmacGenerationFailed:
            return "HMAC generation failed."
        }
    }
}
