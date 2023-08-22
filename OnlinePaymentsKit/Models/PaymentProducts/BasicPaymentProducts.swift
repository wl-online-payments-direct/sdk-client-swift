//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPBasicPaymentProducts)
public class BasicPaymentProducts: NSObject, ResponseObjectSerializable {

    @objc public var paymentProducts = [BasicPaymentProduct]()
    @objc public var stringFormatter: StringFormatter? {
        get { return paymentProducts.first?.stringFormatter }
        set {
            if let stringFormatter = newValue {
                for basicProduct in paymentProducts {
                    basicProduct.stringFormatter = stringFormatter
                }
            }
        }
    }
    @objc public var hasAccountsOnFile: Bool {
        for product in paymentProducts
            where product.accountsOnFile.accountsOnFile.count > 0 {
                return true
        }

        return false
    }

    @objc public var accountsOnFile: [AccountOnFile] {
        var accountsOnFile = [AccountOnFile]()

        for product in paymentProducts {
            accountsOnFile.append(contentsOf: product.accountsOnFile.accountsOnFile)
        }

        return accountsOnFile
    }

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    @objc public override init() {}

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    @objc required public init(json: [String: Any]) {
        guard let paymentProductsInput = json["paymentProducts"] as? [[String: Any]] else {
            return
        }

        for product in paymentProductsInput {
            if let paymentProduct = BasicPaymentProduct(json: product) {
                paymentProducts.append(paymentProduct)
            }
        }
    }

    @objc public func logoPath(forPaymentProduct identifier: String) -> String? {
        let product = paymentProduct(withIdentifier: identifier)
        guard let displayHints = product?.displayHintsList.first else {
            return nil
        }
        return displayHints.logoPath
    }

    @objc public func paymentProduct(withIdentifier identifier: String) -> BasicPaymentProduct? {
        for product in paymentProducts where product.identifier.isEqual(identifier) {
            return product
        }
        return nil
    }

    @objc public func sort() {
        paymentProducts = paymentProducts.sorted {
            let displayOrder0 = $0.displayHintsList[0].displayOrder
            let displayOrder1 = $1.displayHintsList[0].displayOrder

            return displayOrder0 < displayOrder1
        }
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let products = object as? BasicPaymentProducts else {
            return false
        }

        if self.paymentProducts.count != products.paymentProducts.count {
            return false
        }

        for index in 0..<self.paymentProducts.count
          where self.paymentProducts[index] != products.paymentProducts[index] {
            return false
        }
        return true
    }
}
