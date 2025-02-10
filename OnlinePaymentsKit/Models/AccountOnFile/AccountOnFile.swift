//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPAccountOnFile)
public class AccountOnFile: NSObject, Codable {

    @objc public var identifier: String
    @objc public var paymentProductIdentifier: String
    @objc public var displayHints = AccountOnFileDisplayHints()
    @objc public var attributes = AccountOnFileAttributes()
    @objc public var stringFormatter = StringFormatter()

    private enum CodingKeys: String, CodingKey {
        case id, paymentProductId, displayHintsList, attributes, label
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let idInt = try? container.decode(Int.self, forKey: .id) {
            self.identifier = "\(idInt)"
        } else {
            self.identifier = try container.decode(String.self, forKey: .id)
        }

        if let paymentProductIdInt = try? container.decode(Int.self, forKey: .paymentProductId) {
            self.paymentProductIdentifier = "\(paymentProductIdInt)"
        } else {
            self.paymentProductIdentifier = try container.decode(String.self, forKey: .paymentProductId)
        }

        if let displayHints = try? container.decodeIfPresent(AccountOnFileDisplayHints.self, forKey: .displayHintsList) {
            self.displayHints = displayHints
        }

        if let accountOnFileAttributes =
            try? container.decodeIfPresent([AccountOnFileAttribute].self, forKey: .attributes) {
                for accountOnFileAttribute in accountOnFileAttributes {
                    self.attributes.attributes.append(accountOnFileAttribute)
                }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(identifier, forKey: .id)
        try? container.encode(paymentProductIdentifier, forKey: .paymentProductId)
        try? container.encode(displayHints, forKey: .displayHintsList)
        try? container.encode(attributes.attributes, forKey: .attributes)
        try? container.encode(label, forKey: .label)
    }

    @objc public func maskedValue(forField paymentProductFieldId: String) -> String {
        let mask = displayHints.labelTemplate.mask(forAttributeKey: paymentProductFieldId)
        return maskedValue(forField: paymentProductFieldId, mask: mask)
    }

    @objc public func maskedValue(forField paymentProductFieldId: String, mask: String?) -> String {
        let value = attributes.value(forField: paymentProductFieldId)

        if let mask = mask {
            let relaxedMask = stringFormatter.relaxMask(mask: mask)
            return stringFormatter.formatString(string: value, mask: relaxedMask)
        }

        return value
    }

    @objc public func hasValue(forField paymentProductFieldId: String) -> Bool {
        return attributes.hasValue(forField: paymentProductFieldId)
    }

    @objc(fieldIsReadOnly:)
    public func isReadOnly(field paymentProductFieldId: String) -> Bool {
        return attributes.isReadOnly(field: paymentProductFieldId)
    }

    @objc public var label: String {
        var label = ""
        if let labelTemplateItem = displayHints.labelTemplate.labelTemplateItems.first {
            label = maskedValue(forField: labelTemplateItem.attributeKey, mask: labelTemplateItem.mask)
        }

        return label
    }
}
