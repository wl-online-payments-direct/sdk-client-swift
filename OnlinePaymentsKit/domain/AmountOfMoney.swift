/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation

@objc(OPAmountOfMoney) public class AmountOfMoney: NSObject, Codable {
    @objc public var amount = 0
    @objc public var currencyCode: String

    /// AmountOfMoney, contains an amount and Currency Code.
    /// - Parameters:
    ///   - amount: The amount, in the smallest possible denominator of the provided currency.
    ///   - currencyCode: The ISO-4217 Currency Code.
    ///                   See [ISO 4217 Currency Codes](https://www.iso.org/iso-4217-currency-codes.html).
    @objc(initWithAmount:currencyCode:) public init(amount: Int, currencyCode: String) {
        self.amount = amount
        self.currencyCode = currencyCode
    }

    enum CodingKeys: CodingKey {
        case amount, currencyCode
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.amount = try container.decode(Int.self, forKey: .amount)

        if let currencyCodeString = try? container.decodeIfPresent(String.self, forKey: .currencyCode) {
            self.currencyCode = currencyCodeString
        } else {
            self.currencyCode = "UNKNOWN"
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(amount, forKey: .amount)
        try? container.encode(currencyCode, forKey: .currencyCode)
    }

    @objc public override var description: String {
        return "\(amount)-\(currencyCode)"
    }
}
