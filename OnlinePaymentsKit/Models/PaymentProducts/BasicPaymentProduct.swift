//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

@objc(OPBasicPaymentProduct)
public class BasicPaymentProduct: NSObject, BasicPaymentItem, Codable {

    @objc public var identifier: String
    @objc public var displayHints = [PaymentItemDisplayHints]()
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

    internal override init() {
        self.identifier = ""
        self.displayHints = []
        self.accountsOnFile = AccountsOnFile()
        self.paymentMethod = ""
        self.paymentProductGroup = ""
        self.usesRedirectionTo3rdParty = false
        super.init()
    }

    private enum CodingKeys: String, CodingKey {
        case id, displayHintsList, accountsOnFile, allowsTokenization,
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

        self.displayHints =  try container.decodeIfPresent([PaymentItemDisplayHints].self, forKey: .displayHintsList) ?? []
        self.paymentMethod = try container.decode(String.self, forKey: .paymentMethod)

        if let accountsOnFile = try? container.decodeIfPresent([AccountOnFile].self, forKey: .accountsOnFile) {
            for accountOnFile in accountsOnFile {
                self.accountsOnFile.accountsOnFile.append(accountOnFile)
            }
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
        try? container.encode(displayHints, forKey: .displayHintsList)
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
