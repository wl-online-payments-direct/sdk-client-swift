//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

public protocol BasicPaymentItem {
    var identifier: String { get set }
    var displayHints: PaymentItemDisplayHints { get set }
    var accountsOnFile: AccountsOnFile { get set }
}
