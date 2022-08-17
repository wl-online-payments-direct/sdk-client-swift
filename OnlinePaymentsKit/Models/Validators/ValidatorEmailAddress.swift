//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//
import Foundation

@objc(OPValidatorEmailAddress)
public class ValidatorEmailAddress: Validator {
    @objc public var expression: NSRegularExpression

    @objc public override init() {
        let regex = "^[^@\\.]+(\\.[^@\\.]+)*@([^@\\.]+\\.)*[^@\\.]+\\.[^@\\.][^@\\.]+$"

        expression = try! NSRegularExpression(pattern: regex)
    }

    @objc public override func validate(value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)

        let numberOfMatches = expression.numberOfMatches(in: value, range: NSRange(location: 0, length: value.count))
        if numberOfMatches != 1 {
            let error = ValidationErrorEmailAddress()
            errors.append(error)
        }
    }
}
