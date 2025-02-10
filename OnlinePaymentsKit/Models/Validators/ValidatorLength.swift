//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidatorLength)
public class ValidatorLength: Validator, ValidationRule {
    @objc public var minLength = 0
    @objc public var maxLength = 0

    internal init(minLength: Int?, maxLength: Int?) {
        self.minLength = minLength ?? 0
        self.maxLength = maxLength ?? 0

        super.init(messageId: "length", validationType: .length)
    }

    private enum CodingKeys: String, CodingKey {
        case minLength, maxLength
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.minLength = try container.decodeIfPresent(Int.self, forKey: .minLength) ?? 0
        self.maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength) ?? 0

        super.init(messageId: "length", validationType: .length)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try? super.encode(to: encoder)

        try? container.encode(minLength, forKey: .minLength)
        try? container.encode(maxLength, forKey: .maxLength)
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

        if value.count < minLength || value.count > maxLength {
            let error =
                ValidationErrorLength(
                    errorMessage: self.messageId,
                    paymentProductFieldId: fieldId,
                    rule: self
                )
            error.minLength = minLength
            error.maxLength = maxLength
            errors.append(error)

            return false
        }

        return true
    }
}
