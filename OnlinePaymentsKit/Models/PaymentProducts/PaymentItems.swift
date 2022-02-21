//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentItems {

    public var paymentItems = [BasicPaymentItem]()
    public var stringFormatter: StringFormatter?
    public var allPaymentItems = [BasicPaymentItem]()

    public var hasAccountsOnFile: Bool {
        for paymentItem in paymentItems where paymentItem.accountsOnFile.accountsOnFile.count > 0 {
            return true
        }
        return false
    }

    public var accountsOnFile: [AccountOnFile] {
        var accountsOnFile = [AccountOnFile]()

        for paymentItem in paymentItems {
            accountsOnFile.append(contentsOf: paymentItem.accountsOnFile.accountsOnFile)
        }

        return accountsOnFile
    }

    public init(products: BasicPaymentProducts, groups: BasicPaymentProductGroups?) {
        paymentItems = createPaymentItemsFromProducts(products: products, groups: groups)
        allPaymentItems = products.paymentProducts
    }

    public func createPaymentItemsFromProducts(products: BasicPaymentProducts, groups: BasicPaymentProductGroups?) -> [BasicPaymentItem] {
        return products.paymentProducts
    }

    public func logoPath(forItem identifier: String) -> String? {
        guard let item = paymentItem(withIdentifier: identifier) else {
            return nil
        }

        if (item.displayHintsList.isEmpty == false) {
            return item.displayHintsList[0].logoPath
        }else{
            return nil
        }
    }

    public func paymentItem(withIdentifier identifier: String) -> BasicPaymentItem? {
        for paymentItem in allPaymentItems where paymentItem.identifier.isEqual(identifier) {
            return paymentItem
        }

        return nil
    }

    public func sort() {
        paymentItems = paymentItems.sorted {
            guard let displayOrder0 = $0.displayHintsList[0].displayOrder, let displayOrder1 = $1.displayHintsList[0].displayOrder else {
                return false
            }
            return displayOrder0 < displayOrder1
        }
    }
}
