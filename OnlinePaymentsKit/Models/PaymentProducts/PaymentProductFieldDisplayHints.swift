//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentProductFieldDisplayHints)
public class PaymentProductFieldDisplayHints: NSObject, Codable, ResponseObjectSerializable {

    @objc public var alwaysShow = false
    @objc public var displayOrder: Int
    @objc public var formElement: FormElement
    @objc public var mask: String?
    @objc public var obfuscate = false
    @objc public var tooltip: ToolTip?
    @objc public var label: String?
    @objc public var placeholderLabel: String?
    @available(
        *,
        deprecated,
        message: "In a future release, this property will be removed since it is not returned from the API."
    )
    @objc public var link: URL?
    @objc public var preferredInputType: PreferredInputType = .noKeyboard

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    @objc required public init?(json: [String: Any]) {
        guard let input = json["formElement"] as? [String: Any],
            let formElement = FormElement(json: input) else {
            return nil
        }
        self.formElement = formElement

        if let input = json["alwaysShow"] as? Bool {
            alwaysShow = input
        }

        guard let input = json["displayOrder"] as? Int else {
            return nil
        }
        self.displayOrder = input

        if let input = json["mask"] as? String {
            mask = input
        }

        if let input = json["obfuscate"] as? Bool {
            obfuscate = input
        }

        if let input = json["label"] as? String {
            label = input
        }

        if let input = json["placeholderLabel"] as? String {
            placeholderLabel = input
        }

        if let input = json["link"]  as? String {
            link = URL(string: input)
        }

        if let input = json["tooltip"] as? [String: Any] {
            tooltip = ToolTip(json: input)
        }

        super.init()

        if let input = json["preferredInputType"] as? String {
            preferredInputType = self.getPreferredInputType(preferredInputType: input)
        }
    }

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
        self.link = try? container.decodeIfPresent(URL.self, forKey: .link)

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
        try? container.encodeIfPresent(link, forKey: .link)
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
        case .noKeyboard:
            return "NoKeyboard"
        }
    }
}
