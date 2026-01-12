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

@objc(OPValidatorRange) public class ValidatorRange: NSObject, ValidationRule {
    @objc public let messageId: String = "range"
    @objc public let type: ValidationType = .range

    @objc public let minValue: Int
    @objc public let maxValue: Int
    @objc public let formatter = NumberFormatter()

    internal init(minValue: Int?, maxValue: Int?) {
        self.minValue = minValue ?? 0
        self.maxValue = maxValue ?? 0

        super.init()
    }

    @objc public func validate(value: String) -> RuleValidationResult {
        guard let number = formatter.number(from: value) else {
            return RuleValidationResult(
                valid: false,
                message: "Provided value is not a number."
            )
        }

        let intValue = number.intValue
        let isValid = intValue >= minValue && intValue <= maxValue

        return RuleValidationResult(
            valid: isValid,
            message: isValid ? "" : "Provided value must be between \(minValue) and \(maxValue)."
        )
    }
}
