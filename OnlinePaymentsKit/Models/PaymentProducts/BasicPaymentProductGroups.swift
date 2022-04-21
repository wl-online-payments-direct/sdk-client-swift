//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

public class BasicPaymentProductGroups: ResponseObjectSerializable {

    public var paymentProductGroups = [BasicPaymentProductGroup]()

    public var hasAccountsOnFile: Bool {
        for productGroup in paymentProductGroups where productGroup.accountsOnFile.accountsOnFile.count > 0 {
            return true
        }

        return false
    }

    public var accountsOnFile: [AccountOnFile] {
        var accountsOnFile = [AccountOnFile]()

        for productGroup in paymentProductGroups {
            accountsOnFile.append(contentsOf: productGroup.accountsOnFile.accountsOnFile)
        }

        return accountsOnFile
    }

    public var stringFormatter: StringFormatter? {
        get { return paymentProductGroups.first?.stringFormatter }
        set {
            if let stringFormatter = newValue {
                for productGroup in paymentProductGroups {
                    productGroup.stringFormatter = stringFormatter
                }
            }
        }
    }

    public init() {}

    required public init(json: [String: Any]) {
        if let input = json["paymentProductGroups"] as? [[String: Any]] {
            for groupInput in input {
                if let group = BasicPaymentProductGroup(json: groupInput) {
                    paymentProductGroups.append(group)
                }
            }

            sort()
        }
    }

    public func logoPath(forProductGroup identifier: String) -> String? {
        let productGroup = paymentProductGroup(withIdentifier: identifier)
        guard let displayHints = productGroup?.displayHintsList.first else {
            return nil
        }
        return displayHints.logoPath
    }

    public func paymentProductGroup(withIdentifier identifier: String) -> BasicPaymentProductGroup? {
        for productGroup in paymentProductGroups where productGroup.identifier.isEqual(identifier) {
            return productGroup
        }
        return nil
    }

    public func sort() {
        paymentProductGroups = paymentProductGroups.sorted {
            guard let displayOrder0 = $0.displayHintsList[0].displayOrder, let displayOrder1 = $1.displayHintsList[0].displayOrder else {
                return false
            }
            return displayOrder0 < displayOrder1
        }
    }
}
