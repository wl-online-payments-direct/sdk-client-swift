//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentContext)
public class PaymentContext: NSObject {
    public var countryCode: CountryCode
    @objc public var countryCodeString: String
    @objc public var locale = String()
    @objc public var forceBasicFlow = false
    @objc public var amountOfMoney: PaymentAmountOfMoney
    @objc public var isRecurring: Bool
    @objc public init(amountOfMoney: PaymentAmountOfMoney, isRecurring: Bool, countryCode: String) {
        self.amountOfMoney = amountOfMoney
        self.isRecurring = isRecurring
        self.countryCode = CountryCode.init(rawValue: countryCode) ?? .US
        self.countryCodeString = countryCode

        if let languageCode = Locale.current.languageCode {
            self.locale = languageCode.appending("_")
        }
        if let regionCode = Locale.current.regionCode, !self.locale.isEmpty {
            self.locale = self.locale.appending(regionCode)
        }
    }
    
    public init(amountOfMoney: PaymentAmountOfMoney, isRecurring: Bool, countryCode: CountryCode) {
        self.amountOfMoney = amountOfMoney
        self.isRecurring = isRecurring
        self.countryCode = countryCode
        self.countryCodeString = countryCode.rawValue

        if let languageCode = Locale.current.languageCode {
            self.locale = languageCode.appending("_")
        }
        if let regionCode = Locale.current.regionCode, !self.locale.isEmpty {
            self.locale = self.locale.appending(regionCode)
        }
    }

    @objc public override var description: String {
        return "\(amountOfMoney.description)-\(countryCode)-\(isRecurring ? "YES" : "NO")"
    }
}
