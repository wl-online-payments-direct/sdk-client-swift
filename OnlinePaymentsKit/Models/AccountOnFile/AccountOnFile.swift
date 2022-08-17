//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPAccountOnFile)
public class AccountOnFile: NSObject, ResponseObjectSerializable {

    @objc public var identifier: String
    @objc public var paymentProductIdentifier: String
    @objc public var displayHints = AccountOnFileDisplayHints()
    @objc public var attributes = AccountOnFileAttributes()
    @objc public var stringFormatter = StringFormatter()

    @objc public required init?(json: [String: Any]) {

        guard let identifier = json["id"] as? Int,
            let paymentProductId = json["paymentProductId"] as? Int else {
            return nil
        }
        self.identifier = "\(identifier)"
        self.paymentProductIdentifier = "\(paymentProductId)"
        if let input = json["displayHints"] as? [String: Any] {
            if let labelInputs = input["labelTemplate"] as? [[String: Any]] {
                for labelInput in labelInputs {
                    if let label = LabelTemplateItem(json: labelInput) {
                        displayHints.labelTemplate.labelTemplateItems.append(label)
                    }
                }
            }
        }
        if let input = json["attributes"] as? [[String: Any]] {
            for attributeInput in input {
                if let attribute = AccountOnFileAttribute(json: attributeInput) {
                    attributes.attributes.append(attribute)
                }
            }
        }
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
        var labelComponents = [String]()

        for labelTemplateItem in displayHints.labelTemplate.labelTemplateItems {
            let value = maskedValue(forField: labelTemplateItem.attributeKey)
            if !value.isEmpty {
                let trimmedValue = value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                labelComponents.append(trimmedValue)
            }
        }

        return labelComponents.joined(separator: " ")
    }

}
