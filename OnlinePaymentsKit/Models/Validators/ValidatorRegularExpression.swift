//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidatorRegularExpression)
public class ValidatorRegularExpression: Validator, ValidationRule, ResponseObjectSerializable {

    @objc public var regularExpression: NSRegularExpression

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    @objc public init(regularExpression: NSRegularExpression) {
        self.regularExpression = regularExpression

        super.init(messageId: "regularExpression", validationType: .regularExpression)
    }

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    @objc public required init?(json: [String: Any]) {
        guard let input = json["regularExpression"] as? String,
            let regularExpression = try? NSRegularExpression(pattern: input) else {
            Macros.DLog(message: "Expression: \(json["regularExpression"]!) is invalid")
            return nil
        }

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
            Macros.DLog(message: "Regular expression is invalid")
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
