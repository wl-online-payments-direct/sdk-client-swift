//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidatorRegularExpression)
public class ValidatorRegularExpression: Validator, ValidationRule {

    @objc public var regularExpression: NSRegularExpression

    internal init(regularExpression: NSRegularExpression) {
        self.regularExpression = regularExpression

        super.init(messageId: "regularExpression", validationType: .regularExpression)
    }

    private enum CodingKeys: String, CodingKey { case regularExpression, regex }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let regularExpressionInput = try?
                container.decodeIfPresent(String.self, forKey: .regularExpression) ??
                container.decodeIfPresent(String.self, forKey: .regex),
              let regularExpression = try? NSRegularExpression(pattern: regularExpressionInput) else {
            Logger.log("Regular expression is invalid")

            throw SessionError.RuntimeError("Regular expression is invalid")
        }

        self.regularExpression = regularExpression

        super.init(messageId: "regularExpression", validationType: .regularExpression)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try? super.encode(to: encoder)

        try? container.encode(regularExpression.pattern, forKey: .regex)
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

        let numberOfMatches =
            regularExpression.numberOfMatches(in: value, range: NSRange(location: 0, length: value.count))
        if numberOfMatches != 1 {
            let error =
                ValidationErrorRegularExpression(
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
