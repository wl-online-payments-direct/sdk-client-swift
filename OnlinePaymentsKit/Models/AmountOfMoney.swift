//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 31/07/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPAmountOfMoney)
public class AmountOfMoney: NSObject, Codable {
    @objc public var totalAmount = 0
    @objc public var currencyCode: String

    /// AmountOfMoney, contains an amount and Currency Code.
    /// - Parameters:
    ///   - totalAmount: The amount, in the smallest possible denominator of the provided currency.
    ///   - currencyCode: The ISO-4217 Currency Code.
    ///                   See [ISO 4217 Currency Codes](https://www.iso.org/iso-4217-currency-codes.html) .
    @objc(initWithTotalAmount:currencyCode:)
    public init(totalAmount: Int, currencyCode: String) {
        self.totalAmount = totalAmount
        self.currencyCode = currencyCode
    }

    enum CodingKeys: CodingKey {
        case amount, currencyCode
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.totalAmount = try container.decode(Int.self, forKey: .amount)

        if let currencyCodeString = try? container.decodeIfPresent(String.self, forKey: .currencyCode) {
            self.currencyCode = currencyCodeString
        } else {
            self.currencyCode = "UNKNOWN"
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(totalAmount, forKey: .amount)
        try? container.encode(currencyCode, forKey: .currencyCode)
    }

    @objc public override var description: String {
        return "\(totalAmount)-\(currencyCode)"
    }
}
