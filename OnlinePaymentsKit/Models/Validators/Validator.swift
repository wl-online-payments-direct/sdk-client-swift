//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPValidator)
public class Validator: NSObject {
    @objc public var errors: [ValidationError] = []

    @objc(validate:forPaymentRequest:)
    public func validate(value: String, for: PaymentRequest) {
        errors.removeAll()
    }

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    @objc public override init() {
        super.init()
    }
}
