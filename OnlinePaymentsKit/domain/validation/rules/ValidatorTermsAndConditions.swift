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
