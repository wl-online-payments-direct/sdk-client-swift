//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//
import Foundation

@objc(OPPaymentProductFields)
public class PaymentProductFields: NSObject {

    @objc public var paymentProductFields = [PaymentProductField]()

    @objc public func sort() {
        paymentProductFields = paymentProductFields.sorted {
            let displayOrder0 = $0.displayHints.displayOrder
            let displayOrder1 = $1.displayHints.displayOrder
            
            return displayOrder0 < displayOrder1
        }
    }
}
