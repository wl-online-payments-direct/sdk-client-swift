/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation

@objc(OPPaymentProductFieldDisplayHints) public class PaymentProductFieldDisplayHints: NSObject {

    @objc public var alwaysShow = false
    @objc public var displayOrder: Int
    @objc public var formElement: FormElement
    @objc public var mask: String?
    @objc public var obfuscate = false
    @objc public var tooltip: ToolTip?
    @objc public var label: String?
    @objc public var placeholderLabel: String?
    @objc public var preferredInputType: PreferredInputType = .stringKeyboard
    @objc public var link: String?

    internal init(
        alwaysShow: Bool,
        displayOrder: Int,
        formElement: FormElement,
        label: String?,
        link: String?,
        mask: String?,
        obfuscate: Bool,
        placeholderLabel: String?,
        preferredInputType: String?,
        tooltip: ToolTip?
    ) {
        self.alwaysShow = alwaysShow
        self.displayOrder = displayOrder
        self.formElement = formElement
        self.label = label
        self.link = link
        self.mask = mask
        self.obfuscate = obfuscate
        self.placeholderLabel = placeholderLabel
        self.tooltip = tooltip
        self.preferredInputType = Self.getPreferredInputType(preferredInputType: preferredInputType)

        super.init()
    }

    private static func getPreferredInputType(preferredInputType: String?) -> PreferredInputType {
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
