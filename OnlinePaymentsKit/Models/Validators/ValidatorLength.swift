//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidatorLength)
public class ValidatorLength: Validator, ResponseObjectSerializable {
    @objc public var minLength = 0
    @objc public var maxLength = 0

    public init(minLength: Int?, maxLength: Int?) {
        self.minLength = minLength ?? 0
        self.maxLength = maxLength ?? 0
    }

    @objc public required init(json: [String: Any]) {
        if let input = json["maxLength"] as? Int {
            maxLength = input
        }
        if let input = json["minLength"] as? Int {
            minLength = input
        }
    }

    @objc public override func validate(value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)

        let error = ValidationErrorLength()
        error.minLength = minLength
        error.maxLength = maxLength

        if value.count < minLength || value.count > maxLength {
            errors.append(error)
        }
    }
}
