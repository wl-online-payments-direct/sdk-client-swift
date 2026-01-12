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

@objc(OPValidatorFixedList) public class ValidatorFixedList: NSObject, ValidationRule {
    @objc public let messageId: String = "fixedList"
    @objc public let type: ValidationType = .fixedList

    @objc public let allowedValues: [String]

    internal init(allowedValues: [String]) {
        self.allowedValues = allowedValues

        super.init()
    }

    @objc public func validate(value: String) -> RuleValidationResult {
        for allowedValue in allowedValues where allowedValue.isEqual(value) {
            return RuleValidationResult(
                valid: true,
                message: ""
            )
        }

        return RuleValidationResult(
            valid: false,
            message: "Provided value is not allowed."
        )
    }
}
