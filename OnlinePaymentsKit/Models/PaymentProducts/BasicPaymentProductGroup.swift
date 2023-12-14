//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPBasicPaymentProductGroup)
public class BasicPaymentProductGroup: NSObject, Codable, ResponseObjectSerializable, BasicPaymentItem {

    @objc public var identifier: String
    @available(*, deprecated, message: "In the next major release, the type of displayHints will change to List.")
    @objc public var displayHints: PaymentItemDisplayHints
    @objc public var displayHintsList = [PaymentItemDisplayHints]()
    @objc public var accountsOnFile = AccountsOnFile()

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

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    @objc public required init?(json: [String: Any]) {
        guard let identifier = json["id"] as? String,
            let hints = json["displayHints"] as? [String: Any],
            let displayHints = PaymentItemDisplayHints(json: hints) else {
            return nil
        }
        self.identifier = identifier
        self.displayHints = displayHints

        if let input = json["displayHintsList"] as? [[String: Any]] {
            for displayHintInput in input {
                if let displayHint = PaymentItemDisplayHints(json: displayHintInput) {
                    displayHintsList.append(displayHint)
                }
            }
        }

        if let input = json["accountsOnFile"] as? [[String: Any]] {
            for accountInput in input {
                if let account = AccountOnFile(json: accountInput) {
                    accountsOnFile.accountsOnFile.append(account)
                }
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, displayHints, displayHintsList, accountsOnFile
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .id)
        self.displayHints = try container.decode(PaymentItemDisplayHints.self, forKey: .displayHints)
        if let displayHintsList =
            try? container.decodeIfPresent([PaymentItemDisplayHints].self, forKey: .displayHintsList) {
                self.displayHintsList = displayHintsList
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
        try? container.encode(displayHints, forKey: .displayHints)
        try? container.encode(displayHintsList, forKey: .displayHintsList)
        try? container.encode(accountsOnFile.accountsOnFile, forKey: .accountsOnFile)
    }

    @objc public func accountOnFile(withIdentifier identifier: String) -> AccountOnFile? {
        return accountsOnFile.accountOnFile(withIdentifier: identifier)
    }
}
