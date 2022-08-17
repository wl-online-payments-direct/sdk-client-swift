//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPPaymentItem)
public protocol PaymentItem: BasicPaymentItem {
    var fields: PaymentProductFields { get set }

    func paymentProductField(withId paymentProductFieldId: String) -> PaymentProductField?
}
