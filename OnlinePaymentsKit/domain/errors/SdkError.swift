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

public enum SdkErrorType: String {
    case invalidArgumentError = "INVALID_ARGUMENT_ERROR"
    case configurationError = "CONFIGURATION_ERROR"
    case clientError = "CLIENT_ERROR"
    case encryptionError = "ENCRYPTION_ERROR"
}

public typealias SdkErrorMetadata = [String: Any]

@objc(OPSdkError)
open class SdkError: NSObject, Error {
    public let message: String
    public let code: SdkErrorType
    public let metadata: SdkErrorMetadata?

    public init(
        message: String,
        code: SdkErrorType,
        metadata: SdkErrorMetadata? = nil,
    ) {
        self.message = message
        self.code = code
        self.metadata = metadata
    }
}
