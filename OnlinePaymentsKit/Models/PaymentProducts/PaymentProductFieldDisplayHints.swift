//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentProductFieldDisplayHints)
public class PaymentProductFieldDisplayHints: NSObject, Codable {

    @objc public var alwaysShow = false
    @objc public var displayOrder: Int
    @objc public var formElement: FormElement
    @objc public var mask: String?
    @objc public var obfuscate = false
    @objc public var tooltip: ToolTip?
    @objc public var label: String?
    @objc public var placeholderLabel: String?
    @objc public var preferredInputType: PreferredInputType = .stringKeyboard

    private enum CodingKeys: String, CodingKey {
        case alwaysShow, displayOrder, formElement, mask, obfuscate, tooltip, label,
             placeholderLabel, link, preferredInputType
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.formElement = try container.decode(FormElement.self, forKey: .formElement)
        self.displayOrder = try container.decode(Int.self, forKey: .displayOrder)

        if let alwaysShow = try? container.decodeIfPresent(Bool.self, forKey: .alwaysShow) {
            self.alwaysShow = alwaysShow
        }
        self.mask = try? container.decodeIfPresent(String.self, forKey: .mask)
        if let obfuscate = try? container.decodeIfPresent(Bool.self, forKey: .obfuscate) {
            self.obfuscate = obfuscate
        }
        self.tooltip = try? container.decodeIfPresent(ToolTip.self, forKey: .tooltip)
        self.label = try? container.decodeIfPresent(String.self, forKey: .label)
        self.placeholderLabel = try? container.decodeIfPresent(String.self, forKey: .placeholderLabel)

        super.init()

        let preferredInputTypeAsString = try? container.decodeIfPresent(String.self, forKey: .preferredInputType)
        self.preferredInputType = self.getPreferredInputType(preferredInputType: preferredInputTypeAsString)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(alwaysShow, forKey: .alwaysShow)
        try? container.encode(displayOrder, forKey: .displayOrder)
        try? container.encode(formElement, forKey: .formElement)
        try? container.encodeIfPresent(mask, forKey: .mask)
        try? container.encode(obfuscate, forKey: .obfuscate)
        try? container.encodeIfPresent(tooltip, forKey: .tooltip)
        try? container.encodeIfPresent(label, forKey: .label)
        try? container.encodeIfPresent(placeholderLabel, forKey: .placeholderLabel)
        try? container.encode(
            getPreferredInputTypeString(preferredInputType: preferredInputType),
            forKey: .preferredInputType
        )
    }

    private func getPreferredInputType(preferredInputType: String?) -> PreferredInputType {
        switch preferredInputType {
        case "StringKeyboard":
            return .stringKeyboard
        case "IntegerKeyboard":
            return .integerKeyboard
        case "EmailAddressKeyboard":
            return .emailAddressKeyboard
        case "PhoneNumberKeyboard":
            return .phoneNumberKeyboard
        case "DateKeyboard":
            return .dateKeyboard
        default:
            return .stringKeyboard
        }
    }

    private func getPreferredInputTypeString(preferredInputType: PreferredInputType) -> String {
        switch preferredInputType {
        case .stringKeyboard:
            return "StringKeyboard"
        case .integerKeyboard:
            return "IntegerKeyboard"
        case .emailAddressKeyboard:
            return "EmailAddressKeyboard"
        case .phoneNumberKeyboard:
            return "PhoneNumberKeyboard"
        case .dateKeyboard:
            return "DateKeyboard"
        }
    }
}
