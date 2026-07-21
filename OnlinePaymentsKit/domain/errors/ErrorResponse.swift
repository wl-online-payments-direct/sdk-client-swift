/*
 * Do not remove or alter the notices in this preamble.
 *
 * This software is owned by Worldline and may not be be altered, copied, reproduced, republished, uploaded, posted, transmitted or distributed in any way, without the prior written consent of Worldline.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation

@objc(OPErrorResponse) public class ErrorResponse: NSObject, Codable {
    @objc public let errorId: String
    @objc public let errors: [ApiErrorItem]

    public init(errorId: String, errors: [ApiErrorItem]) {
        self.errorId = errorId
        self.errors = errors
    }
}

extension ErrorResponse {
    public var raw: SdkErrorMetadata {
        [
            "errorId": errorId,
            "errors": errors.map {
                $0.raw
            },
        ]
    }
}
