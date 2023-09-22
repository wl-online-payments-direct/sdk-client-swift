//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 31/07/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPAmountOfMoney)
public class AmountOfMoney: NSObject, ResponseObjectSerializable {
    @objc public var totalAmount = 0
    @available(
        *,
        deprecated,
        message: "Use currencyCodeString instead. In a future release, this field will become 'String' type."
    )
    public var currencyCode: CurrencyCode
    @objc public var currencyCodeString: String

    public required init?(json: [String : Any]) {
        guard let totalAmount = json["amount"] as? Int,
            let currencyCode = json["currencyCode"] as? String else {
            return nil
        }

        self.totalAmount = totalAmount
        self.currencyCode = CurrencyCode.init(rawValue: currencyCode) ?? .UNKNOWN
        self.currencyCodeString = currencyCode
    }

    @available(*, deprecated, message: "Use init(Int, String) instead")
    public convenience init(totalAmount: Int, currencyCode: CurrencyCode) {
        self.init(totalAmount: totalAmount, currencyCode: currencyCode.rawValue)
    }

    /// AmountOfMoney, contains an amount and Currency Code.
    /// - Parameters:
    ///   - totalAmount: The amount, in the smallest possible denominator of the provided currency.
    ///   - currencyCode: The ISO-4217 Currency Code.
    ///                   See [ISO 4217 Currency Codes](https://www.iso.org/iso-4217-currency-codes.html) .
    @objc(initWithTotalAmount:currencyCode:)
    public init(totalAmount: Int, currencyCode: String) {
        self.totalAmount = totalAmount
        self.currencyCode = CurrencyCode.init(rawValue: currencyCode) ?? .UNKNOWN
        self.currencyCodeString = currencyCode
    }

    @objc public override var description: String {
        return "\(totalAmount)-\(currencyCodeString)"
    }
}
