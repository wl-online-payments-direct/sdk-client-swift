//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorTermsAndConditions: Validator {
    public override init() {
        super.init()
    }

    public override func validate(value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)
        if (!(Bool(value) ?? false)) {
            let error = ValidationErrorTermsAndConditions()
            errors.append(error)
        }
    }
}
