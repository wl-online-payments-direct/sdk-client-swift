//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentProductFieldDisplayHints)
public class PaymentProductFieldDisplayHints: NSObject, ResponseObjectSerializable {

    @objc public var alwaysShow = false
    @objc public var displayOrder: Int
    @objc public var formElement: FormElement
    @objc public var mask: String?
    @objc public var obfuscate = false
    @objc public var tooltip: ToolTip?
    @objc public var label: String?
    @objc public var placeholderLabel: String?
    @objc public var link: URL?
    @objc public var preferredInputType: PreferredInputType = .noKeyboard

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
        if let input = json["preferredInputType"] as? String {
            switch input {
            case "StringKeyboard":
                preferredInputType = .stringKeyboard
            case "IntegerKeyboard":
                preferredInputType = .integerKeyboard
            case "EmailAddressKeyboard":
                preferredInputType = .emailAddressKeyboard
            case "PhoneNumberKeyboard":
                preferredInputType = .phoneNumberKeyboard
            case "DateKeyboard":
                preferredInputType = .dateKeyboard
            default:
                break
            }
        }

        if let input = json["tooltip"] as? [String: Any] {
            tooltip = ToolTip(json: input)
        }
    }
}
