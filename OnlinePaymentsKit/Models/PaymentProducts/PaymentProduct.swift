//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentProduct: BasicPaymentProduct, PaymentItem {

    public var fields: PaymentProductFields = PaymentProductFields()

    public required init?(json: [String: Any]) {
        super.init(json: json)

        guard let input = json["fields"] as? [[String: Any]] else {
            return
        }

        for fieldInput in input {
            if let field = PaymentProductField(json: fieldInput) {
                fields.paymentProductFields.append(field)
            }
        }
    }

    public func paymentProductField(withId: String) -> PaymentProductField? {
        for field in fields.paymentProductFields where field.identifier.isEqual(withId) {
            return field
        }
        return nil
    }
}
