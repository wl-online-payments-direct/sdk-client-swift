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

/// Thread-safe payment request using a concurrent dispatch queue with barrier writes.
///
/// This implementation uses the reader-writer pattern where:
/// - Multiple reads can happen concurrently
/// - Writes are exclusive and block other operations
@objc(OPPaymentRequest) public final class PaymentRequest: NSObject {

    @objc public let paymentProduct: PaymentProduct

    private var accountOnFileStorage: AccountOnFile?
    @objc public var accountOnFile: AccountOnFile? {
        queue.sync {
            accountOnFileStorage
        }
    }

    @objc public var tokenize: Bool = false

    private var fields: [String: PaymentRequestField] = [:]
    private let queue = DispatchQueue(
        label: "com.worldline.onlinepayments.paymentRequest",
        attributes: .concurrent
    )

    @objc public init(paymentProduct: PaymentProduct, accountOnFile: AccountOnFile? = nil, tokenize: Bool = false) {
        self.paymentProduct = paymentProduct
        self.accountOnFileStorage = accountOnFile
        self.tokenize = tokenize
        super.init()
    }

    /// Returns the field with the specified ID, creating it lazily if it doesn't exist.
    ///
    /// - Parameter id: The field identifier
    /// - Returns: The payment request field
    /// - Throws: `InvalidArgumentError` if the field ID is not found in the payment product
    ///
    /// - Warning: This method returns a mutable reference to a field object. If you hold onto this reference
    ///   and later call `setAccountOnFile(_:)`, some fields may be removed from the internal dictionary.
    ///   Held references will still exist but may become inconsistent with the payment request state.
    ///   To avoid issues, always call `field(id:)` again after calling `setAccountOnFile(_:)`.
    @objc public func field(id: String) throws -> PaymentRequestField {
        return try queue.sync(flags: .barrier) {
            try _field(id: id)
        }
    }

    // Internal method - assumes lock is already held
    private func _field(id: String) throws -> PaymentRequestField {
        var readOnly = false
        if let accountOnFile = accountOnFileStorage {
            readOnly = !accountOnFile.isWritable(id: id)
        }

        if fields[id] == nil {
            guard let definition = paymentProduct.field(id: id) else {
                throw InvalidArgumentError(message: "Field '\(id)' not found in payment product")
            }

            fields[id] = PaymentRequestField(definition: definition, readOnly: readOnly)
        }

        guard let field = fields[id] else {
            throw InvalidArgumentError(message: "Field '\(id)' not found in payment product")
        }

        return field
    }

    @objc public func values() -> [String: String] {
        return queue.sync {
            var result: [String: String] = [:]

            for (key, field) in fields {
                if let value = field.value {
                    result[key] = value
                }
            }

            return result
        }
    }

    @objc public func setAccountOnFile(_ accountOnFile: AccountOnFile?) {
        queue.sync(flags: .barrier) {
            guard let accountOnFile = accountOnFile else {
                self.accountOnFileStorage = nil
                return
            }

            let fieldsToRemove = fields.values.filter {
                field in
                !accountOnFile.isWritable(id: field.id)
            }.map {
                $0.id
            }

            fieldsToRemove.forEach {
                _ = fields.removeValue(forKey: $0)
            }
            self.accountOnFileStorage = accountOnFile
        }
    }

    @objc public func validate() throws -> ValidationResult {
        return try queue.sync(flags: .barrier) {
            var allErrors: [ValidationErrorMessage] = []

            if let accountOnFile = accountOnFileStorage, !accountOnFile.getRequiredAttributes().isEmpty {
                let requiredAttributes = accountOnFile.getRequiredAttributes()

                let requiredFields = paymentProduct.fields.filter {
                    field in
                    requiredAttributes.contains {
                        attr in
                        field.id == attr.key
                    }
                }

                try validateFields(requiredFields, errors: &allErrors)
            } else {
                try validateFields(paymentProduct.fields, errors: &allErrors)
            }

            return ValidationResult(isValid: allErrors.isEmpty, errors: allErrors)
        }
    }

    @objc public func value(id: String) -> String? {
        return queue.sync {
            fields[id]?.value
        }
    }

    @objc public func setValue(id: String, value: String) throws {
        try field(id: id).setValue(value: value)
    }

    // Internal method - assumes lock is already held
    private func validateFields(_ fields: [PaymentProductField], errors: inout [ValidationErrorMessage]) throws {
        guard !fields.isEmpty else {
            return
        }

        try fields.forEach {
            fieldDefinition in
            let field = try self._field(id: fieldDefinition.id)
            let result = field.validate()
            errors.append(contentsOf: result.errors)
        }
    }
}
