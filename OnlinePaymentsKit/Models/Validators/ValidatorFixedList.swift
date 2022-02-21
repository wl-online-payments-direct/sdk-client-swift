//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorFixedList: Validator, ResponseObjectSerializable {
    public var allowedValues: [String] = []

    public init(allowedValues: [String]) {
        self.allowedValues = allowedValues
    }

    required public init(json: [String: Any]) {
        if let input = json["allowedValues"] as? [String] {
            for inputString in input {
                allowedValues.append(inputString)
            }
        }
    }

    public override func validate(value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)

        for allowedValue in allowedValues where allowedValue.isEqual(value) {
            return
        }

        let error = ValidationErrorFixedList()
        errors.append(error)
    }
}
