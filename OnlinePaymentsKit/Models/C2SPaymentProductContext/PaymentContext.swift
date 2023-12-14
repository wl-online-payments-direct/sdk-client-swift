//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentContext)
public class PaymentContext: NSObject, Decodable {
    @available(
        *,
        deprecated,
        message: "Use countryCodeString instead. In a future release, this field will become 'String' type."
    )
    public var countryCode: CountryCode
    @objc public var countryCodeString: String
    @objc public var locale = String()
    @available(*, deprecated, message: "In a future release, this field will be removed.")
    @objc public var forceBasicFlow = false
    @available(*, deprecated, message: "In a future release, the type of this field will become 'AmountOfMoney'.")
    @objc public var amountOfMoney: PaymentAmountOfMoney
    @objc public var isRecurring: Bool

    @available(*, deprecated, message: "Use init(AmountOfMoney:Bool:String:) instead")
    public convenience init(amountOfMoney: PaymentAmountOfMoney, isRecurring: Bool, countryCode: CountryCode) {
        self.init(amountOfMoney: amountOfMoney, isRecurring: isRecurring, countryCode: countryCode.rawValue)
    }

    /// PaymentContext, contains information about the payment to be made.
    /// - Parameters:
    ///   - amountOfMoney: The AmountOfMoney object which contains the total amount and the currency code.
    ///   - isRecurring: Indicates whether the payment will be recurring or not.
    ///   - countryCode: The Country Code of the Country where the transaction will take place.
    ///                  The provided code should match the ISO-3166-alpha-2 standard.
    ///                  See [ISO 3166 Country Codes](https://www.iso.org/iso-3166-country-codes.html) .
    @objc(initWithAmountOfMoney:isRecurring:countryCode:)
    public init(amountOfMoney: AmountOfMoney, isRecurring: Bool, countryCode: String) {
        self.amountOfMoney = amountOfMoney.cloneToDeprecatedObject()
        self.isRecurring = isRecurring
        self.countryCode = CountryCode.init(rawValue: countryCode) ?? .UNKNOWN
        self.countryCodeString = countryCode

        if let languageCode = Locale.current.languageCode {
            self.locale = languageCode.appending("_")
        }
        if let regionCode = Locale.current.regionCode, !self.locale.isEmpty {
            self.locale = self.locale.appending(regionCode)
        }
    }

    enum CodingKeys: CodingKey {
        case countryCode, forceBasicFlow, amountOfMoney, isRecurring
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let countryCodeString = try? container.decodeIfPresent(String.self, forKey: .countryCode) {
            self.countryCodeString = countryCodeString
            self.countryCode = CountryCode.init(rawValue: countryCodeString) ?? .UNKNOWN
        } else {
            self.countryCodeString = "UNKNOWN"
            self.countryCode = .UNKNOWN
        }

        if let forceBasicFlow = try? container.decodeIfPresent(Bool.self, forKey: .forceBasicFlow) {
            self.forceBasicFlow = forceBasicFlow
        }

        self.amountOfMoney = try container.decode(PaymentAmountOfMoney.self, forKey: .amountOfMoney)

        self.isRecurring = try container.decodeIfPresent(Bool.self, forKey: .isRecurring) ?? false

        if let languageCode = Locale.current.languageCode {
            self.locale = languageCode.appending("_")
        }
        if let regionCode = Locale.current.regionCode, !self.locale.isEmpty {
            self.locale = self.locale.appending(regionCode)
        }
    }

    @objc public override var description: String {
        return "\(amountOfMoney.description)-\(countryCodeString)-\(isRecurring ? "YES" : "NO")"
    }
}
