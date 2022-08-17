//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidatorLuhn)
public class ValidatorLuhn: Validator {

    @objc public override func validate (value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)

        var evenSum = 0
        var oddSum = 0
        var digit = 0

        for i in 1 ... value.count {
            let j = value.count - i
            digit = Int(value[j])!

            if i % 2 == 1 {
                evenSum += digit
            } else {
                digit = digit * 2
                digit = (digit % 10) + (digit / 10)
                oddSum += digit
            }
        }

        let total = evenSum + oddSum
        if total % 10 != 0 {
            let error = ValidationErrorLuhn()
            errors.append(error)
        }
    }

}
