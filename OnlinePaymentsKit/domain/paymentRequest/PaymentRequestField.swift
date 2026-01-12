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

@objc(OPPaymentRequestField) public final class PaymentRequestField: NSObject {

    private let definition: PaymentProductField
    private let readOnly: Bool
    private var storedValue: String?

    internal init(definition: PaymentProductField, readOnly: Bool) {
        self.definition = definition
        self.readOnly = readOnly
        super.init()
    }

    public var value: String? {
        storedValue
    }

    public func setValue(value: String?) throws {
        if readOnly {
            throw InvalidArgumentError(
                message: "Cannot write \"READ_ONLY\" field: \(definition.id)"
            )
        }

        if let value, !value.isEmpty {
            storedValue = definition.removeMask(value: value)
        } else {
            storedValue = nil
        }
    }

    public var maskedValue: String? {
        definition.applyMask(value: storedValue)
    }

    public func clearValue() {
        storedValue = nil
    }

    public var id: String {
        definition.id
    }

    public var label: String {
        definition.label
    }

    public var placeholder: String? {
        definition.placeholder
    }

    public var isRequired: Bool {
        definition.isRequired
    }

    public var shouldObfuscate: Bool {
        definition.shouldObfuscate
    }

    public var type: FieldType? {
        definition.type
    }

    public func formatForDisplay(value: String? = nil) -> String? {
        definition.applyMask(value: value)
    }

    public func validate() -> ValidationResult {
        let errors = definition.validate(value: storedValue)
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
}
