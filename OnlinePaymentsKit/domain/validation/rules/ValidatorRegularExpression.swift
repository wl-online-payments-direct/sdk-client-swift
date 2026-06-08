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

@objc(OPValidatorRegularExpression) public class ValidatorRegularExpression: NSObject, ValidationRule {
    @objc public let messageId: String = "regularExpression"
    @objc public let type: ValidationType = .regularExpression

    @objc public let regularExpression: NSRegularExpression

    internal init(regularExpression: NSRegularExpression) {
        self.regularExpression = regularExpression

        super.init()
    }

    @objc public func validate(value: String) -> RuleValidationResult {
        let numberOfMatches = regularExpression.numberOfMatches(
            in: value,
            range: NSRange(location: 0, length: value.count)
        )
        let isValid = numberOfMatches == 1

        return RuleValidationResult(
            valid: isValid,
            message: isValid ? "" : "Provided value is not in the correct format."
        )
    }
}
