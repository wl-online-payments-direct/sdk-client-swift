//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//
import Foundation

@objc(OPValidatorEmailAddress)
public class ValidatorEmailAddress: Validator, ValidationRule {
    @objc public var expression: NSRegularExpression

    internal override init() {
        let regex = "^[^@\\.]+(\\.[^@\\.]+)*@([^@\\.]+\\.)*[^@\\.]+\\.[^@\\.][^@\\.]+$"

        guard let regex = try? NSRegularExpression(pattern: regex) else {
            fatalError("Could not create Regular Expression")
        }
        expression = regex

        super.init(messageId: "emailAddress", validationType: .emailAddress)
    }

    required init(from decoder: Decoder) throws {
        let regex = "^[^@\\.]+(\\.[^@\\.]+)*@([^@\\.]+\\.)*[^@\\.]+\\.[^@\\.][^@\\.]+$"

        guard let regex = try? NSRegularExpression(pattern: regex) else {
            fatalError("Could not create Regular Expression")
        }
        expression = regex

        super.init(messageId: "emailAddress", validationType: .emailAddress)
    }

    @available(
        *,
        deprecated,
        message: "In a future release, this function will be removed. Please use validate(field:in:) instead."
    )
    @objc(validate:forPaymentRequest:)
    public override func validate(value: String, for request: PaymentRequest) {
        _ = validate(value: value)
    }

    @objc public func validate(field fieldId: String, in request: PaymentRequest) -> Bool {
        guard let fieldValue = request.getValue(forField: fieldId) else {
            return false
        }

        return validate(value: fieldValue, for: fieldId)
    }

    @objc public func validate(value: String) -> Bool {
        validate(value: value, for: nil)
    }

    internal override func validate(value: String, for fieldId: String?) -> Bool {
        self.clearErrors()

        let numberOfMatches = expression.numberOfMatches(in: value, range: NSRange(location: 0, length: value.count))
        if numberOfMatches != 1 {
            let error =
                ValidationErrorEmailAddress(
                    errorMessage: self.messageId,
                    paymentProductFieldId: fieldId,
                    rule: self
                )
            errors.append(error)
            return false
        }
        return true
    }
}
