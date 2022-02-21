//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

public protocol BasicPaymentItem {
    var identifier: String { get set }
    @available(*, deprecated, message: "In the next major release, the type of displayHints will change to List.")
    var displayHints: PaymentItemDisplayHints { get set }
    var displayHintsList: [PaymentItemDisplayHints] { get set }
    var accountsOnFile: AccountsOnFile { get set }
}
