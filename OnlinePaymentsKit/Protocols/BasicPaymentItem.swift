//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPBasicPaymentItem)
public protocol BasicPaymentItem {
    @objc var identifier: String { get set }
    @objc var displayHints: [PaymentItemDisplayHints] { get set }
    @objc var accountsOnFile: AccountsOnFile { get set }
}
