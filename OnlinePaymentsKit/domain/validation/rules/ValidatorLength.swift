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

@objc(OPValidatorLength) public class ValidatorLength: NSObject, ValidationRule {
    @objc public let messageId: String = "length"
    @objc public let type: ValidationType = .length

    @objc public let minLength: Int
    @objc public let maxLength: Int

    internal init(minLength: Int?, maxLength: Int?) {
        self.minLength = minLength ?? 0
        self.maxLength = maxLength ?? 0

        super.init()
    }

    @objc public func validate(value: String) -> RuleValidationResult {
        let isValid = value.count >= minLength && value.count <= maxLength

        return RuleValidationResult(
            valid: isValid,
            message: isValid ? "" : "Provided value does not have an allowed length."
        )
    }
}
