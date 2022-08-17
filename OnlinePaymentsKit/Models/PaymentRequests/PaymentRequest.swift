//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentRequest)
public class PaymentRequest: NSObject {

    @objc public var paymentProduct: PaymentProduct?
    @objc public var errors: [ValidationError] = []
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

    @objc(setValue:forField:)
    public func setValue(forField paymentProductFieldId: String, value: String) {
        fieldValues[paymentProductFieldId] = value
    }

    @objc public func getValue(forField paymentProductFieldId: String) -> String? {
        if let value = fieldValues[paymentProductFieldId] {
            return value
        }

        var value: String?
        if let paymentProduct = paymentProduct, let field = paymentProduct.paymentProductField(withId: paymentProductFieldId),
            let fixedListValidator = field.dataRestrictions.validators.validators.filter({ $0 is ValidatorFixedList }).first as? ValidatorFixedList,
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
        guard  let value = getValue(forField: paymentProductFieldId) else {
            return nil
        }
        if let mask = mask(forField: paymentProductFieldId) {
            return formatter.unformatString(string: value, mask: mask)
        }

        return value
    }

    @objc public func isPartOfAccountOnFile(field paymentProductFieldId: String) -> Bool {
        return accountOnFile?.hasValue(forField: paymentProductFieldId) ?? false
    }

    @objc public func isReadOnly(field paymentProductFieldId: String) -> Bool {
        if !isPartOfAccountOnFile(field: paymentProductFieldId) {
            return false
        } else if let accountOnFile = accountOnFile {
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

    @objc public func validate() {
        guard let paymentProduct = paymentProduct else {
            NSException(name: NSExceptionName(rawValue: "Invalid payment product"), reason: "Payment product is invalid").raise()
            return
        }

        errors.removeAll()

        for field in paymentProduct.fields.paymentProductFields {
            if let fieldValue = unmaskedValue(forField: field.identifier),
                !isPartOfAccountOnFile(field: field.identifier) {
                field.validateValue(value: fieldValue, for: self)
                errors.append(contentsOf: field.errors)
            }
        }
    }

    @objc public var unmaskedFieldValues: [String: String]? {
        guard let paymentProduct = paymentProduct else {
            NSException(name: NSExceptionName(rawValue: "Invalid payment product"), reason: "Payment product is invalid").raise()
            return nil
        }

        var unmaskedFieldValues = [String: String]()

        for field in paymentProduct.fields.paymentProductFields where !isReadOnly(field: field.identifier) {
            let unmasked = unmaskedValue(forField: field.identifier)
            unmaskedFieldValues[field.identifier] = unmasked
        }

        return unmaskedFieldValues
    }
}
