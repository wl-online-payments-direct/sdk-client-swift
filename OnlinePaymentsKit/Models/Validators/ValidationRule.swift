//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 10/08/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import Foundation

@objc public protocol ValidationRule {
    func validate(value: String) -> Bool
    func validate(field fieldId: String, in request: PaymentRequest) -> Bool
}
