/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation

@objc(OPBasicPaymentProducts) public class BasicPaymentProducts: NSObject {

    @objc public internal(set) var paymentProducts: [BasicPaymentProduct] = []
    @objc public private(set) var accountsOnFile: [AccountOnFile]

    internal init(paymentProducts: [BasicPaymentProduct]) {
        self.paymentProducts = paymentProducts

        // Collect unique accountsOnFile from all products
        var allAccounts: [AccountOnFile] = []
        var seenIds = Set<String>()

        for product in paymentProducts {
            for account in product.accountsOnFile {
                if !seenIds.contains(account.id) {
                    seenIds.insert(account.id)
                    allAccounts.append(account)
                }
            }
        }

        self.accountsOnFile = allAccounts

        super.init()
    }

    @objc public func paymentProduct(withId id: Int) -> BasicPaymentProduct? {
        return paymentProducts.first {
            $0.id == id
        }
    }

    @objc public func accountOnFile(withId id: String) -> AccountOnFile? {
        return accountsOnFile.first {
            $0.id == id
        }
    }

    internal func setPaymentProducts(_ products: [BasicPaymentProduct]) {
        self.paymentProducts = products
    }
}
