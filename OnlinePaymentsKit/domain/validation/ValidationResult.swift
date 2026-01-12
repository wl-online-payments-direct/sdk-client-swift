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

@objc public final class ValidationResult: NSObject, Codable {

    @objc public let isValid: Bool
    @objc public let errors: [ValidationErrorMessage]

    @objc public init(
        isValid: Bool,
        errors: [ValidationErrorMessage] = []
    ) {
        self.isValid = isValid
        self.errors = errors
        super.init()
    }

    private enum CodingKeys: String, CodingKey {
        case isValid
        case errors
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isValid = try container.decode(Bool.self, forKey: .isValid)
        self.errors = try container.decode([ValidationErrorMessage].self, forKey: .errors)
        super.init()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isValid, forKey: .isValid)
        try container.encode(errors, forKey: .errors)
    }
}

extension ValidationResult {
    var raw: [String: Any] {
        [
            "isValid": isValid,
            "errors": errors.map {
                $0.raw
            },
        ]
    }
}
