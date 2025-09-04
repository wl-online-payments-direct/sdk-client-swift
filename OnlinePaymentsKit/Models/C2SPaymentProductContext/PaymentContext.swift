//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentContext)
public class PaymentContext: NSObject, Decodable {
    @objc public var countryCode: String
    @available(*, deprecated, message: "The 'locale' property is deprecated. Do not use it (no replacement needed).")
    @objc public var locale = String()
    @objc public var amountOfMoney: AmountOfMoney
    @objc public var isRecurring: Bool

    /// PaymentContext, contains information about the payment to be made.
    /// - Parameters:
    ///   - amountOfMoney: The AmountOfMoney object which contains the total amount and the currency code.
    ///   - isRecurring: Indicates whether the payment will be recurring or not.
    ///   - countryCode: The Country Code of the Country where the transaction will take place.
    ///                  The provided code should match the ISO-3166-alpha-2 standard.
    ///                  See [ISO 3166 Country Codes](https://www.iso.org/iso-3166-country-codes.html) .
    @objc(initWithAmountOfMoney:isRecurring:countryCode:)
    public init(amountOfMoney: AmountOfMoney, isRecurring: Bool, countryCode: String) {
        self.amountOfMoney = amountOfMoney
        self.isRecurring = isRecurring
        self.countryCode = countryCode
    }

    enum CodingKeys: CodingKey {
        case countryCode, amountOfMoney, isRecurring
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let countryCodeString = try? container.decodeIfPresent(String.self, forKey: .countryCode) {
            self.countryCode = countryCodeString
        } else {
            self.countryCode = "UNKNOWN"
        }

        self.amountOfMoney = try container.decode(AmountOfMoney.self, forKey: .amountOfMoney)

        self.isRecurring = try container.decodeIfPresent(Bool.self, forKey: .isRecurring) ?? false
    }

    @objc public override var description: String {
        return "\(amountOfMoney.description)-\(countryCode)-\(isRecurring ? "YES" : "NO")"
    }
}
