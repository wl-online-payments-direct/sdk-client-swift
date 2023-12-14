//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

@objc(OPBasicPaymentProduct)
public class BasicPaymentProduct: NSObject, BasicPaymentItem, Codable, ResponseObjectSerializable {

    @objc public var identifier: String
    @available(*, deprecated, message: "In the next major release, the type of displayHints will change to List.")
    @objc public var displayHints: PaymentItemDisplayHints
    @objc public var displayHintsList = [PaymentItemDisplayHints]()
    @objc public var accountsOnFile = AccountsOnFile()

    @objc public var allowsTokenization = false
    @objc public var allowsRecurring = false

    @objc public var paymentMethod: String

    @objc public var paymentProductGroup: String?

    @objc public var paymentProduct302SpecificData: PaymentProduct302SpecificData?
    @objc public var paymentProduct320SpecificData: PaymentProduct320SpecificData?

    @objc public var usesRedirectionTo3rdParty: Bool

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

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    @objc public override init() {
        self.identifier = ""
        self.displayHints = PaymentItemDisplayHints()
        self.displayHintsList = []
        self.accountsOnFile = AccountsOnFile()
        self.paymentMethod = ""
        self.paymentProductGroup = ""
        self.usesRedirectionTo3rdParty = false
        super.init()
    }

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    @objc public required init?(json: [String: Any]) {
        guard let identifier = json["id"] as? Int,
            let paymentMethod = json["paymentMethod"] as? String,
            let hints = json["displayHints"] as? [String: Any],
            let displayHints = PaymentItemDisplayHints(json: hints),
            let usesRedirectionTo3rdParty = json["usesRedirectionTo3rdParty"] as? Bool
            else {
                return nil
        }

        if let input = json["displayHintsList"] as? [[String: Any]] {
            for displayHintInput in input {
                if let displayHint = PaymentItemDisplayHints(json: displayHintInput) {
                    displayHintsList.append(displayHint)
                }
            }
        }

        if let paymentProduct302SpecificDataDictionary = json["paymentProduct302SpecificData"] as? [String: Any],
            let paymentProduct302SpecificData =
                PaymentProduct302SpecificData(json: paymentProduct302SpecificDataDictionary) {
            self.paymentProduct302SpecificData = paymentProduct302SpecificData
        }

        if let paymentProduct320SpecificDataDictionary = json["paymentProduct320SpecificData"] as? [String: Any],
            let paymentProduct320SpecificData =
                PaymentProduct320SpecificData(json: paymentProduct320SpecificDataDictionary) {
            self.paymentProduct320SpecificData = paymentProduct320SpecificData
        }

        self.identifier = "\(identifier)"
        self.paymentMethod = paymentMethod
        self.displayHints = displayHints
        self.usesRedirectionTo3rdParty = usesRedirectionTo3rdParty

        paymentProductGroup = json["paymentProductGroup"] as? String

        allowsRecurring = json["allowsRecurring"] as? Bool ?? false

        if let input = json["accountsOnFile"] as? [[String: Any]] {
            for accountInput in input {
                if let account = AccountOnFile(json: accountInput) {
                    accountsOnFile.accountsOnFile.append(account)
                }
            }
        }

        allowsTokenization = json["allowsTokenization"] as? Bool ?? false
    }

    private enum CodingKeys: String, CodingKey {
        case id, displayHints, displayHintsList, accountsOnFile, allowsTokenization,
             allowsRecurring, paymentMethod, paymentProductGroup, paymentProduct302SpecificData,
             paymentProduct320SpecificData, usesRedirectionTo3rdParty
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            self.identifier = "\(idInt)"
        } else {
            self.identifier = try container.decode(String.self, forKey: .id)
        }
        self.displayHints =
            try container.decodeIfPresent(PaymentItemDisplayHints.self, forKey: .displayHints) ??
            PaymentItemDisplayHints()
        self.paymentMethod = try container.decode(String.self, forKey: .paymentMethod)

        if let accountsOnFile = try? container.decodeIfPresent([AccountOnFile].self, forKey: .accountsOnFile) {
            for accountOnFile in accountsOnFile {
                self.accountsOnFile.accountsOnFile.append(accountOnFile)
            }
        }
        if let displayHintsList =
            try? container.decodeIfPresent([PaymentItemDisplayHints].self, forKey: .displayHintsList) {
                self.displayHintsList = displayHintsList
        }
        if let allowsTokenization = try? container.decodeIfPresent(Bool.self, forKey: .allowsTokenization) {
            self.allowsTokenization = allowsTokenization
        }
        if let allowsRecurring = try? container.decodeIfPresent(Bool.self, forKey: .allowsRecurring) {
            self.allowsRecurring = allowsRecurring
        }
        self.paymentProductGroup = try? container.decodeIfPresent(String.self, forKey: .paymentProductGroup)
        self.paymentProduct302SpecificData =
            try? container.decodeIfPresent(PaymentProduct302SpecificData.self, forKey: .paymentProduct302SpecificData)
        self.paymentProduct320SpecificData =
            try? container.decodeIfPresent(PaymentProduct320SpecificData.self, forKey: .paymentProduct320SpecificData)
        self.usesRedirectionTo3rdParty = try container.decode(Bool.self, forKey: .usesRedirectionTo3rdParty)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(identifier, forKey: .id)
        try? container.encode(displayHints, forKey: .displayHints)
        try? container.encode(displayHintsList, forKey: .displayHintsList)
        try? container.encode(accountsOnFile.accountsOnFile, forKey: .accountsOnFile)
        try? container.encode(allowsTokenization, forKey: .allowsTokenization)
        try? container.encode(allowsRecurring, forKey: .allowsRecurring)
        try? container.encode(paymentMethod, forKey: .paymentMethod)
        try? container.encodeIfPresent(paymentProductGroup, forKey: .paymentProductGroup)
        try? container.encodeIfPresent(paymentProduct302SpecificData, forKey: .paymentProduct302SpecificData)
        try? container.encodeIfPresent(paymentProduct320SpecificData, forKey: .paymentProduct320SpecificData)
        try? container.encode(usesRedirectionTo3rdParty, forKey: .usesRedirectionTo3rdParty)
    }

    @objc public func accountOnFile(withIdentifier identifier: String) -> AccountOnFile? {
        return accountsOnFile.accountOnFile(withIdentifier: identifier)
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let product = object as? BasicPaymentProduct else {
            return false
        }

        return self.identifier == product.identifier
    }
}
