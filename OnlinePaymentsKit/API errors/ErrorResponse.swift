//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 18/07/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPErrorResponse)
public class ErrorResponse: NSObject, Codable {
    @objc public let message: String
    @objc public let apiError: ApiError?

    public init(message: String, apiError: ApiError? = nil) {
        self.message = message
        self.apiError = apiError
    }
}
