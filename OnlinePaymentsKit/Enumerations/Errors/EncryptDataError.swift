//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 28/09/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPEncryptDataError)
public enum EncryptDataError: Int, Error {
    case publicKeyDecodeError
    case rsaKeyNotFound
}

extension EncryptDataError: LocalizedError {
    public var errorDescription: String {
        switch self {
        case .publicKeyDecodeError:
            return "Failed to decode Public key."
        case .rsaKeyNotFound:
            return "Failed to find RSA key."
        }
    }
}
