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

@objc(OPValidatorTermsAndConditions) public class ValidatorTermsAndConditions: NSObject, ValidationRule {
    @objc public let messageId: String = "termsAndConditions"
    @objc public let type: ValidationType = .termsAndConditions

    internal override init() {
        super.init()
    }

    @objc public func validate(value: String) -> RuleValidationResult {
        let isValid = Bool(value) ?? false

        return RuleValidationResult(
            valid: isValid,
            message: isValid ? "" : "Please accept terms and conditions."
        )
    }
}
