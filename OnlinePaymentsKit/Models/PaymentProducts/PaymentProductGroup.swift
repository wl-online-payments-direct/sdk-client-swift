//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentProductGroup)
public class PaymentProductGroup: NSObject, Codable, PaymentItem {

    @objc public var identifier: String
    @objc public var displayHints = [PaymentItemDisplayHints]()
    @objc public var accountsOnFile = AccountsOnFile()
    @objc public var allowsTokenization = false
    @objc public var allowsRecurring = false
    @objc public var fields = PaymentProductFields()

    @objc public var stringFormatter: StringFormatter? {
        get { return accountsOnFile.accountsOnFile.first?.stringFormatter }
        set {
            if let stringFormatter = newValue {
                for accountOnFile in accountsOnFile.accountsOnFile {
                    accountOnFile.stringFormatter = stringFormatter
                }
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, displayHintsList, accountsOnFile
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .id)
        if let displayHints =
            try? container.decodeIfPresent([PaymentItemDisplayHints].self, forKey: .displayHintsList) {
                self.displayHints = displayHints
        }

        if let accountsOnFile = try? container.decodeIfPresent([AccountOnFile].self, forKey: .accountsOnFile) {
            for accountOnFile in accountsOnFile {
                self.accountsOnFile.accountsOnFile.append(accountOnFile)
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(identifier, forKey: .id)
        try? container.encode(displayHints, forKey: .displayHintsList)
        try? container.encode(accountsOnFile.accountsOnFile, forKey: .accountsOnFile)
    }

    @objc public func accountOnFile(withIdentifier identifier: String) -> AccountOnFile? {
        return accountsOnFile.accountOnFile(withIdentifier: identifier)
    }

    @objc public func paymentProductField(withId paymentProductFieldId: String) -> PaymentProductField? {
        for field in fields.paymentProductFields where field.identifier.isEqual(paymentProductFieldId) {
            return field
        }

        return nil
    }
}
