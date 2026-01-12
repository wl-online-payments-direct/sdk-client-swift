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

@objc(OPPaymentContext) public class PaymentContext: NSObject, Decodable {
    @objc public var countryCode: String
    @objc public var amountOfMoney: AmountOfMoney
    @objc public var isRecurring: Bool

    /// PaymentContext, contains information about the payment to be made.
    /// - Parameters:
    ///   - amountOfMoney: The AmountOfMoney object which contains the total amount and the currency code.
    ///   - isRecurring: Indicates whether the payment will be recurring or not.
    ///   - countryCode: The Country Code of the Country where the transaction will take place.
    ///                  The provided code should match the ISO-3166-alpha-2 standard.
    ///                  See [ISO 3166 Country Codes](https://www.iso.org/iso-3166-country-codes.html) .

    @objc(initWithAmountOfMoney:isRecurring:countryCode:) public init(
        amountOfMoney: AmountOfMoney,
        isRecurring: Bool,
        countryCode: String
    ) {
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
        return "\(amountOfMoney.description)-\(countryCode)-\(isRecurring ? "YES": "NO")"
    }
}
