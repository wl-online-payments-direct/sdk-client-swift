//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//
import Foundation

@objc(OPPaymentAmountOfMoney)
public class PaymentAmountOfMoney: NSObject {
    @objc public var totalAmount = 0
    @available(
        *,
        deprecated,
        message: "Use currencyCodeString instead. In a future release this field will become 'String' type."
    )
    public var currencyCode: CurrencyCode
    @objc public var currencyCodeString: String

    @available(*, deprecated, message: "Use init(Int, String) instead")
    public convenience init(totalAmount: Int, currencyCode: CurrencyCode) {
        self.init(totalAmount: totalAmount, currencyCode: currencyCode.rawValue)
    }

    /// PaymentAmountOfMoney, contains an amount and Currency Code.
    /// - Parameters:
    ///   - totalAmount: The amount, in the smallest possible denominator of the provided currency.
    ///   - currencyCode: The ISO-4217 Currency Code.
    ///                   See [ISO 4217 Currency Codes](https://www.iso.org/iso-4217-currency-codes.html) .
    @objc public init(totalAmount: Int, currencyCode: String) {
        self.totalAmount = totalAmount
        self.currencyCode = CurrencyCode.init(rawValue: currencyCode) ?? .UNKNOWN
        self.currencyCodeString = currencyCode
    }

    @objc public override var description: String {
        return "\(totalAmount)-\(currencyCodeString)"
    }

}
