/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

public class ResponseError: SdkError {
    public let httpStatusCode: Int?

    public init(
        httpStatusCode: Int? = nil,
        message: String?,
        data: ErrorResponse? = nil,
    ) {
        self.httpStatusCode = httpStatusCode

        super.init(
            message: message ?? "Invalid response.",
            code: .clientError,
            metadata: data?.raw,
        )
    }
}
