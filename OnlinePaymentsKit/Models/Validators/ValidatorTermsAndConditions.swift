//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidatorTermsAndConditions)
public class ValidatorTermsAndConditions: Validator, ValidationRule {
    internal override init() {
        super.init(messageId: "termsAndConditions", validationType: .termsAndConditions)
    }

    // periphery:ignore:parameters decoder
    required init(from decoder: Decoder) throws {
        super.init(messageId: "termsAndConditions", validationType: .termsAndConditions)
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

        if !(Bool(value) ?? false) {
            let error =
                ValidationErrorTermsAndConditions(
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
