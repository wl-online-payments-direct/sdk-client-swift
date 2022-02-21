//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentContext {
    public var countryCode: CountryCode
    public var locale: String?
    public var forceBasicFlow: Bool?
    public var amountOfMoney: PaymentAmountOfMoney
    public var isRecurring: Bool
    public init(amountOfMoney: PaymentAmountOfMoney, isRecurring: Bool, countryCode: CountryCode) {
        self.amountOfMoney = amountOfMoney
        self.isRecurring = isRecurring
        self.countryCode = countryCode

        if let languageCode = Locale.current.languageCode {
            self.locale = languageCode.appending("_")
        }
        if let regionCode = Locale.current.regionCode, self.locale != nil {
            self.locale = self.locale!.appending(regionCode)
        }
    }

    public var description: String {
        return "\(amountOfMoney.description)-\(countryCode)-\(isRecurring ? "YES" : "NO")"
    }
}
