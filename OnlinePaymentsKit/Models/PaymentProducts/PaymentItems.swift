//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentItems)
public class PaymentItems: NSObject {

    @objc public var paymentItems = [BasicPaymentItem]()
    @objc public var stringFormatter: StringFormatter?
    @objc public var allPaymentItems = [BasicPaymentItem]()

    @objc public var hasAccountsOnFile: Bool {
        for paymentItem in paymentItems where paymentItem.accountsOnFile.accountsOnFile.count > 0 {
            return true
        }
        return false
    }

    @objc public var accountsOnFile: [AccountOnFile] {
        var accountsOnFile = [AccountOnFile]()

        for paymentItem in paymentItems {
            accountsOnFile.append(contentsOf: paymentItem.accountsOnFile.accountsOnFile)
        }

        return accountsOnFile
    }

    internal init(products: BasicPaymentProducts, groups: BasicPaymentProductGroups?) {
        super.init()
        paymentItems = createPaymentItemsFromProducts(products: products, groups: groups)
        allPaymentItems = products.paymentProducts
    }

    // swiftlint:disable todo
    // TODO: SMBO-96367 - Parameter 'groups' is unused
    // swiftlint:enable todo
    // periphery:ignore
    @objc(createPaymentItemsFromProducts:groups:)
    public func createPaymentItemsFromProducts(
        products: BasicPaymentProducts,
        groups: BasicPaymentProductGroups?
    ) -> [BasicPaymentItem] {
        return products.paymentProducts
    }

    @objc(logoPathForPaymentItem:)
    public func logoPath(forItem identifier: String) -> String? {
        guard let item = paymentItem(withIdentifier: identifier) else {
            return nil
        }

        guard let displayHints = item.displayHints.first else {
            return nil
        }

        return displayHints.logoPath
    }

    @objc public func paymentItem(withIdentifier identifier: String) -> BasicPaymentItem? {
        for paymentItem in allPaymentItems where paymentItem.identifier.isEqual(identifier) {
            return paymentItem
        }

        return nil
    }

    @objc public func sort() {
        paymentItems = paymentItems.sorted {
            let displayOrder0 = $0.displayHints[0].displayOrder
            let displayOrder1 = $1.displayHints[0].displayOrder

            return displayOrder0 < displayOrder1
        }
    }
}
