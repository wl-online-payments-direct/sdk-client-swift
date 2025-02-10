//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidatorRange)
public class ValidatorRange: Validator, ValidationRule {
    @objc public var minValue = 0
    @objc public var maxValue = 0
    @objc public var formatter = NumberFormatter()

    internal init(minValue: Int?, maxValue: Int?) {
        self.minValue = minValue ?? 0
        self.maxValue = maxValue ?? 0

        super.init(messageId: "range", validationType: .range)
    }

    private enum CodingKeys: String, CodingKey { case minValue, maxValue }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.minValue = try container.decodeIfPresent(Int.self, forKey: .minValue) ?? 0
        self.maxValue = try container.decodeIfPresent(Int.self, forKey: .maxValue) ?? 0

        super.init(messageId: "range", validationType: .range)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try? super.encode(to: encoder)

        try? container.encode(minValue, forKey: .minValue)
        try? container.encode(maxValue, forKey: .maxValue)
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

        let error = ValidationErrorRange(errorMessage: self.messageId, paymentProductFieldId: fieldId, rule: self)
        error.minValue = minValue
        error.maxValue = maxValue

        guard let number = formatter.number(from: value) else {
            errors.append(error)

            return false
        }

        if Int(truncating: number) < minValue || Int(truncating: number) > maxValue {
            errors.append(error)

            return false
        }

        return true
    }
}
