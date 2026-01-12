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

@objc(OPPaymentProductField) public class PaymentProductField: NSObject {

    @objc public let id: String
    @objc public let type: FieldType
    @objc public let displayHints: PaymentProductFieldDisplayHints
    @objc public let dataRestrictions: DataRestrictions

    private let stringFormatter = StringFormatter()

    internal init(
        id: String,
        type: FieldType,
        displayHints: PaymentProductFieldDisplayHints,
        dataRestrictions: DataRestrictions
    ) {
        self.id = id
        self.type = type
        self.displayHints = displayHints
        self.dataRestrictions = dataRestrictions

        super.init()
    }

    @objc public var label: String {
        displayHints.label ?? id
    }

    @objc public var placeholder: String? {
        displayHints.placeholderLabel
    }

    @objc public var isRequired: Bool {
        dataRestrictions.isRequired
    }

    @objc public var shouldObfuscate: Bool {
        displayHints.obfuscate
    }

    @objc public func applyMask(value: String?) -> String? {
        guard let value = value, let mask = displayHints.mask else {
            return value
        }

        return stringFormatter.formatString(string: value, mask: mask)
    }

    @objc public func removeMask(value: String?) -> String? {
        guard let value = value, let mask = displayHints.mask else {
            return value
        }

        return stringFormatter.unformatString(string: value, mask: mask)
    }

    @objc public func validate(value: String?) -> [ValidationErrorMessage] {
        if let value = value, !value.isEmpty {
            return dataRestrictions.validationRules.compactMap {
                validator in
                let result = validator.validate(value: value)
                if !result.valid {
                    return ValidationErrorMessage(
                        errorMessage: result.message,
                        paymentProductFieldId: id,
                        type: validator.type.stringValue
                    )
                }
                return nil
            }
        } else if dataRestrictions.isRequired {
            return [
                ValidationErrorMessage(
                    errorMessage: "Field required.",
                    paymentProductFieldId: id,
                    type: "RequiredField"
                )
            ]
        } else {
            return []
        }
    }
}
