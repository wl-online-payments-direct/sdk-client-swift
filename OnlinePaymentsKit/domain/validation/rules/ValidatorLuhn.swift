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

@objc(OPValidatorLuhn) public class ValidatorLuhn: NSObject, ValidationRule {
    @objc public let messageId: String = "luhn"
    @objc public let type: ValidationType = .luhn

    internal override init() {
        super.init()
    }

    @objc public func validate(value: String) -> RuleValidationResult {
        let isValid = modulo(of: value, modulo: 10) == 0

        return RuleValidationResult(
            valid: isValid,
            message: isValid ? "" : "Card number is in invalid format."
        )
    }

    private func modulo(of value: String, modulo: Int) -> Int {
        var evenSum = 0
        var oddSum = 0

        for index in 1...value.count {
            let reversedIndex = value.count - index
            guard var digit = Int(value[reversedIndex]) else {
                return 1
            }

            if index % 2 == 1 {
                evenSum += digit
            } else {
                digit *= 2
                digit = (digit % 10) + (digit / 10)
                oddSum += digit
            }
        }

        let total = evenSum + oddSum

        return total % modulo
    }
}
