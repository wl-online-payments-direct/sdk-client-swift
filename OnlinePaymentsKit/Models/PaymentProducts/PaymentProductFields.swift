//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//
import Foundation

public class PaymentProductFields {

    public var paymentProductFields = [PaymentProductField]()

    public func sort() {
        paymentProductFields = paymentProductFields.sorted {
            guard let displayOrder0 = $0.displayHints.displayOrder, let displayOrder1 = $1.displayHints.displayOrder else {
                return false
            }
            return displayOrder0 < displayOrder1
        }
    }
}
