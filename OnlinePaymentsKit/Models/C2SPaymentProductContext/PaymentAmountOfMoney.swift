//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//
import Foundation

public class PaymentAmountOfMoney {
    public var totalAmount = 0
    public var currencyCode: CurrencyCode

    public init(totalAmount: Int, currencyCode: CurrencyCode) {
        self.totalAmount = totalAmount
        self.currencyCode = currencyCode
    }

    public var description: String {
        return "\(totalAmount)-\(currencyCode)"
    }

}
