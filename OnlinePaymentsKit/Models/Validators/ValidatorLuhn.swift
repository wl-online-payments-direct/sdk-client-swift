//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidatorLuhn)
public class ValidatorLuhn: Validator, ValidationRule {

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    @objc public override init() {
        super.init(messageId: "luhn", validationType: .luhn)
    }

    required init(from decoder: Decoder) throws {
        super.init(messageId: "luhn", validationType: .luhn)
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

        if modulo(of: value, modulo: 10) != 0 {
            let error =
                ValidationErrorLuhn(
                    errorMessage: self.messageId,
                    paymentProductFieldId: fieldId,
                    rule: self
                )
            errors.append(error)

            return false
        }

        return true
    }

    private func modulo(of value: String, modulo: Int) -> Int {
        var evenSum = 0
        var oddSum = 0

        for index in 1 ... value.count {
            let reversedIndex = value.count - index
            guard var digit = Int(value[reversedIndex]) else {
                return 1
            }

            if index % 2 == 1 {
                evenSum += digit
            } else {
                digit *= 2
                digit = (digit % 10) + (digit / 10)
                oddSum += digit
            }
        }

        let total = evenSum + oddSum
        return total % modulo
    }
}
