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

/// Validates a response object and invokes appropriate callbacks.
///
/// - Parameters:
///   - responseObject: The response object to validate
///   - statusCode: HTTP status code from the response
///   - message: Error message to use if validation fails
///   - onValidated: Callback invoked with the validated response object
///   - failure: Callback invoked with an error if validation fails
internal func validateResponse<T>(
    _ responseObject: T?,
    statusCode: Int?,
    message: String,
    success: @escaping (T) -> Void,
    failure: @escaping (SdkError) -> Void
) {
    guard let responseObject = responseObject else {
        let error = ResponseError(httpStatusCode: statusCode, message: message)
        failure(error)
        return
    }

    success(responseObject)
}
