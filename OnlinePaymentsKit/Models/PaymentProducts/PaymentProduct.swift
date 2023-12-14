//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentProduct)
public class PaymentProduct: BasicPaymentProduct, PaymentItem {

    @objc public var fields: PaymentProductFields = PaymentProductFields()

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    @objc public override init() {
        super.init()
    }

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    @objc public required init?(json: [String: Any]) {
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

    private enum CodingKeys: String, CodingKey {
        case fields
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let fieldsInput = try container.decodeIfPresent([PaymentProductField].self, forKey: .fields) {
            for field in fieldsInput {
                self.fields.paymentProductFields.append(field)
            }
        }

        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super.encode(to: encoder)
        try? container.encode(fields.paymentProductFields, forKey: .fields)
    }

    @objc public func paymentProductField(withId: String) -> PaymentProductField? {
        for field in fields.paymentProductFields where field.identifier.isEqual(withId) {
            return field
        }
        return nil
    }
}
