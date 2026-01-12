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

@objc(OPValidationError) public class ValidationErrorMessage: NSObject, Codable {
    @objc public var errorMessage: String = ""
    @objc public var paymentProductFieldId: String?
    @objc public var type: String?

    @objc public override init() {
    }

    @objc public init(errorMessage: String, paymentProductFieldId: String?, type: String?) {
        self.errorMessage = errorMessage
        self.paymentProductFieldId = paymentProductFieldId
        self.type = type
    }
}

extension ValidationErrorMessage {
    var raw: [String: Any] {
        let raw: [String: Any?] = [
            "errorMessage": errorMessage,
            "paymentProductFieldId": paymentProductFieldId,
            "type": type,
        ]
        return raw.compactMapValues {
            $0
        }
    }
}
