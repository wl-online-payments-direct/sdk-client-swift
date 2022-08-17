//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//
import Foundation

@objc(OPPaymentAmountOfMoney)
public class PaymentAmountOfMoney: NSObject {
    @objc public var totalAmount = 0
    public var currencyCode: CurrencyCode
    @objc public var currencyCodeString: String

    @objc public init(totalAmount: Int, currencyCode: String) {
        self.totalAmount = totalAmount
        self.currencyCode = CurrencyCode.init(rawValue: currencyCode) ?? .USD
        self.currencyCodeString = currencyCode
    }
    
    public init(totalAmount: Int, currencyCode: CurrencyCode) {
        self.totalAmount = totalAmount
        self.currencyCode = currencyCode
        self.currencyCodeString = currencyCode.rawValue
    }

    @objc public override var description: String {
        return "\(totalAmount)-\(currencyCode)"
    }

}
