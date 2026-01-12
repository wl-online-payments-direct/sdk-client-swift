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

@objc(OPRuleValidationResult) public class RuleValidationResult: NSObject {

    @objc public let valid: Bool
    @objc public let message: String

    @objc public init(valid: Bool, message: String) {
        self.valid = valid
        self.message = message
        super.init()
    }
}
