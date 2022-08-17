//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentProductGroup)
public class PaymentProductGroup: NSObject, PaymentItem, ResponseObjectSerializable {

    @objc public var identifier: String
    @available(*, deprecated, message: "In the next major release, the type of displayHints will change to List.")
    @objc public var displayHints: PaymentItemDisplayHints
    @objc public var displayHintsList = [PaymentItemDisplayHints]()
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

    @objc public required init?(json: [String: Any]) {

        guard let identifier = json["id"] as? String,
            let hints = json["displayHints"] as? [String: Any],
            let displayHints = PaymentItemDisplayHints(json: hints),
            let fields = json["fields"] as? [[String: Any]] else {
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
                if let accountFile = AccountOnFile(json: accountInput) {
                    accountsOnFile.accountsOnFile.append(accountFile)
                }
            }
        }

        for field in fields {
            if let paymentProductField = PaymentProductField(json: field) {
                self.fields.paymentProductFields.append(paymentProductField)
            }
        }
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
