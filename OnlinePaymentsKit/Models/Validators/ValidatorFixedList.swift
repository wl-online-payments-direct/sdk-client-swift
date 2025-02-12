//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidatorFixedList)
public class ValidatorFixedList: Validator, ValidationRule {
    @objc public var allowedValues: [String] = []

    internal init(allowedValues: [String]) {
        self.allowedValues = allowedValues

        super.init(messageId: "fixedList", validationType: .fixedList)
    }

    private enum CodingKeys: String, CodingKey {
        case allowedValues
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let allowedValues = try? container.decodeIfPresent([String].self, forKey: .allowedValues) {
            self.allowedValues = allowedValues
        }

        super.init(messageId: "fixedList", validationType: .fixedList)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try? super.encode(to: encoder)

        try? container.encode(allowedValues, forKey: .allowedValues)
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

        for allowedValue in allowedValues where allowedValue.isEqual(value) {
            return true
        }

        let error =
            ValidationErrorFixedList(
                errorMessage: self.messageId,
                paymentProductFieldId: fieldId,
                rule: self
            )
        errors.append(error)

        return false
    }
}
