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

@objc(OPValidatorEmailAddress) public class ValidatorEmailAddress: NSObject, ValidationRule {
    @objc public let messageId: String = "emailAddress"
    @objc public let type: ValidationType = .emailAddress

    @objc public let expression: NSRegularExpression

    internal override init() {
        let regex = "^[^@\\.]+(\\.[^@\\.]+)*@([^@\\.]+\\.)*[^@\\.]+\\.[^@\\.][^@\\.]+$"

        guard let regex = try? NSRegularExpression(pattern: regex) else {
            fatalError("Could not create Regular Expression")
        }
        expression = regex

        super.init()
    }

    @objc public func validate(value: String) -> RuleValidationResult {
        let numberOfMatches = expression.numberOfMatches(in: value, range: NSRange(location: 0, length: value.count))

        if numberOfMatches != 1 {
            return RuleValidationResult(
                valid: false,
                message: "Email address is not in the correct format."
            )
        }

        return RuleValidationResult(
            valid: true,
            message: ""
        )
    }
}
