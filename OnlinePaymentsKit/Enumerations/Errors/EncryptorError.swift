//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 21.1.25.
// Copyright © 2025 Global Collect Services. All rights reserved.
// 

import Foundation

public enum EncryptorError: Error {
    case encryptionFailed(Error)
    case decryptionFailed(Error)
}

internal let errorDomain = "com.onlinepayments.sdk.encryptor"

extension EncryptorError {
    public var asNSError: NSError {
        switch self {
        case .encryptionFailed(let err):
            return NSError(domain: errorDomain, code: 1001, userInfo: [
                NSLocalizedDescriptionKey: "Encryption failed: \(err.localizedDescription)",
                NSUnderlyingErrorKey: err
            ])
        case .decryptionFailed(let err):
            return NSError(domain: errorDomain, code: 1002, userInfo: [
                NSLocalizedDescriptionKey: "Decryption failed: \(err.localizedDescription)",
                NSUnderlyingErrorKey: err
            ])
        }
    }
}
