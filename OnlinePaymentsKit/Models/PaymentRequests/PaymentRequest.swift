//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentRequest)
public class PaymentRequest: NSObject, Codable {

    @objc public var paymentProduct: PaymentProduct?
    @objc public var errorMessageIds: [ValidationError] = []
    @objc public var tokenize = false

    @objc public var fieldValues = [String: String]()
    @objc public var formatter = StringFormatter()

    @objc public var accountOnFile: AccountOnFile?

    @objc public override init() {}

    @objc public init(paymentProduct: PaymentProduct, accountOnFile: AccountOnFile? = nil, tokenize: Bool = false) {
        self.paymentProduct = paymentProduct
        self.accountOnFile = accountOnFile
        self.tokenize = tokenize
    }

    private enum CodingKeys: String, CodingKey {
        case paymentProduct, errorMessageIds, tokenize, fieldValues, accountOnFile
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.paymentProduct = try container.decodeIfPresent(PaymentProduct.self, forKey: .paymentProduct)
        self.errorMessageIds = try container.decodeIfPresent([ValidationError].self, forKey: .errorMessageIds) ?? []
        self.tokenize = try container.decode(Bool.self, forKey: .tokenize)
        self.fieldValues =
            try container.decodeIfPresent([String: String].self, forKey: .fieldValues) ?? [String: String]()
        self.accountOnFile = try? container.decodeIfPresent(AccountOnFile.self, forKey: .accountOnFile)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(paymentProduct, forKey: .paymentProduct)
        try? container.encode(errorMessageIds, forKey: .errorMessageIds)
        try? container.encode(tokenize, forKey: .tokenize)
        try? container.encode(fieldValues, forKey: .fieldValues)
        try? container.encodeIfPresent(accountOnFile, forKey: .accountOnFile)
    }

    @objc(setValueForField:value:)
    public func setValue(forField paymentProductFieldId: String, value: String) {
        fieldValues[paymentProductFieldId] = value
    }

    @objc(valueForField:)
    public func getValue(forField paymentProductFieldId: String) -> String? {
        if let value = fieldValues[paymentProductFieldId] {
            return value
        }

        var value: String?
        if let paymentProduct = paymentProduct,
           let field = paymentProduct.paymentProductField(withId: paymentProductFieldId),
            let fixedListValidator =
                field.dataRestrictions.validators.validators.filter({ $0 is ValidatorFixedList }).first
                    as? ValidatorFixedList,
            let allowedValue = fixedListValidator.allowedValues.first {
            value = allowedValue
            setValue(forField: paymentProductFieldId, value: allowedValue)
        }

        return value
    }

    @objc public func maskedValue(forField paymentProductFieldId: String) -> String? {
        guard let value = getValue(forField: paymentProductFieldId) else {
            return nil
        }

        if let mask = mask(forField: paymentProductFieldId) {
            return formatter.formatString(string: value, mask: mask)
        }

        return value
    }

    @objc public func unmaskedValue(forField paymentProductFieldId: String) -> String? {
        guard let value = getValue(forField: paymentProductFieldId) else {
            return nil
        }

        if let mask = mask(forField: paymentProductFieldId) {
            return formatter.unformatString(string: value, mask: mask)
        }

        return value
    }

    @objc(fieldIsPartOfAccountOnFile:)
    public func isPartOfAccountOnFile(field paymentProductFieldId: String) -> Bool {
        return accountOnFile?.hasValue(forField: paymentProductFieldId) ?? false
    }

    private func isPartOfAccountOnFileAndNotModified(field paymentProductFieldId: String) -> Bool {
        if let accountOnFile,
           !accountOnFile.attributes.attributes.isEmpty {
            for attribute in accountOnFile.attributes.attributes {
                if attribute.key == paymentProductFieldId &&
                    (!attribute.isEditingAllowed() || getValue(forField: paymentProductFieldId) == nil) {
                    return true
                }
            }
        }

        return false
    }

    @objc(fieldIsReadOnly:)
    public func isReadOnly(field paymentProductFieldId: String) -> Bool {
        if !isPartOfAccountOnFile(field: paymentProductFieldId) {
            return false
        }
        
        if let accountOnFile = accountOnFile {
            return accountOnFile.isReadOnly(field: paymentProductFieldId)
        }
        
        return false
    }

    @objc public func mask(forField paymentProductFieldId: String) -> String? {
        guard let paymentProduct = paymentProduct else {
            return nil
        }
        let field = paymentProduct.paymentProductField(withId: paymentProductFieldId)
        let mask = field?.displayHints.mask

        return mask
    }

    @objc public func validate() -> [ValidationError] {
        errorMessageIds.removeAll()

        guard let paymentProduct = paymentProduct else {
            errorMessageIds.append(ValidationErrorInvalidPaymentProduct())
            return errorMessageIds
        }

        for field in paymentProduct.fields.paymentProductFields where
          !isPartOfAccountOnFileAndNotModified(field: field.identifier) {
                if unmaskedValue(forField: field.identifier) != nil {
                    let fieldErrors = field.validateValue(for: self)
                    errorMessageIds.append(contentsOf: fieldErrors)
                } else {
                    let error =
                        ValidationErrorIsRequired(
                            errorMessage: "required",
                            paymentProductFieldId: field.identifier,
                            rule: nil
                        )
                    errorMessageIds.append(error)
                }
        }

        return errorMessageIds
    }

    @objc public var maskedFieldValues: [String: String]? {
        guard let paymentProduct = paymentProduct else {
            NSException(
                name: NSExceptionName(rawValue: "Invalid payment product"),
                reason: "Payment product is invalid"
            ).raise()

            return nil
        }

        var maskedFieldValues = [String: String]()

        for field in paymentProduct.fields.paymentProductFields {
            let masked = maskedValue(forField: field.identifier)
            maskedFieldValues[field.identifier] = masked
        }

        return maskedFieldValues
    }

    @objc public var unmaskedFieldValues: [String: String]? {
        guard let paymentProduct = paymentProduct else {
            NSException(
                name: NSExceptionName(rawValue: "Invalid payment product"),
                reason: "Payment product is invalid"
            ).raise()

            return nil
        }

        var unmaskedFieldValues = [String: String]()

        for field in paymentProduct.fields.paymentProductFields {
            let unmasked = unmaskedValue(forField: field.identifier)
            unmaskedFieldValues[field.identifier] = unmasked
        }

        return unmaskedFieldValues
    }

    @objc public func removeValue(forField paymentProductFieldId: String) {
        guard paymentProduct != nil else {
            NSException(
                name: NSExceptionName(rawValue: "Cannot remove value from PaymentRequest"),
                reason: "Payment product is invalid"
            ).raise()

            return
        }

        fieldValues.removeValue(forKey: paymentProductFieldId)
    }
}
