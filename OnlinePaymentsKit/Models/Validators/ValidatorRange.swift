//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidatorRange)
public class ValidatorRange: Validator, ResponseObjectSerializable {
    @objc public var minValue = 0
    @objc public var maxValue = 0
    @objc public var formatter = NumberFormatter()

    public init(minValue: Int?, maxValue: Int?) {
        self.minValue = minValue ?? 0
        self.maxValue = maxValue ?? 0
    }

    @objc required public init(json: [String: Any]) {
        if let input = json["maxValue"] as? Int {
            maxValue = input
        }
        if let input = json["minValue"] as? Int {
            minValue = input
        }
    }

    @objc public override func validate(value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)

        let error = ValidationErrorRange()
        error.minValue = minValue
        error.maxValue = maxValue

        guard let number = formatter.number(from: value) else {
            errors.append(error)
            return
        }

        if Int(truncating: number) < minValue {
            errors.append(error)
        } else if Int(truncating: number) > maxValue {
            errors.append(error)
        }
    }
}
