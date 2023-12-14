//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentProductField)
public class PaymentProductField: NSObject, Codable, ResponseObjectSerializable {

    @objc public var identifier: String
    @available(
        *,
        deprecated,
        message: "In a future release, this property will be removed since it is not returned from the API."
    )
    @objc public var usedForLookup: Bool = false
    @objc public var dataRestrictions = DataRestrictions()
    @objc public var displayHints: PaymentProductFieldDisplayHints
    @objc public var type: FieldType = .string

    @available(*, deprecated, message: "In a future release, this property will become private to this class.")
    @objc public var numberFormatter = NumberFormatter()
    @available(*, deprecated, message: "In a future release, this property will become private to this class.")
    @objc public var numericStringCheck: NSRegularExpression

    @objc public var errorMessageIds: [ValidationError] = []
    @available(
        *,
        deprecated,
        message: "In a future release, this property will be removed. Use errorMessageIds instead."
    )
    @objc public var errors: [ValidationError] = []

    private let stringFormatter = StringFormatter()

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    @objc public required init?(json: [String: Any]) {
        guard let identifier = json["id"] as? String,
              let hints = json["displayHints"] as? [String: Any],
              let displayHints = PaymentProductFieldDisplayHints(json: hints),
              let numericStringCheck = try? NSRegularExpression(pattern: "^\\d+$") else {
            return nil
        }
        self.identifier = identifier
        self.displayHints = displayHints

        numberFormatter.numberStyle = .decimal
        self.numericStringCheck = numericStringCheck

        if let input = json["dataRestrictions"] as? [String: Any] {
            dataRestrictions = DataRestrictions(json: input)
        }

        if let usedForLookup = json["usedForLookup"] as? Bool {
            self.usedForLookup = usedForLookup
        }

        switch json["type"] as? String {
        case "string"?:
            type = .string
        case "integer"?:
            type = .integer
        case "expirydate"?:
            type = .expirationDate
        case "numericstring"?:
            type = .numericString
        case "boolean"?:
            type = .boolString
        case "date"?:
            type = .dateString
        default:
            Macros.DLog(message: "PaymentProductField type: \(json["type"]!) is invalid")
            return nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, usedForLookup, dataRestrictions, displayHints, type
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .id)
        self.displayHints = try container.decode(PaymentProductFieldDisplayHints.self, forKey: .displayHints)
        if let dataRestrictions = try? container.decodeIfPresent(DataRestrictions.self, forKey: .dataRestrictions) {
            self.dataRestrictions = dataRestrictions
        }
        if let usedForLookup = try? container.decodeIfPresent(Bool.self, forKey: .usedForLookup) {
            self.usedForLookup = usedForLookup
        }

        self.numberFormatter.numberStyle = .decimal
        guard let numericStringCheck = try? NSRegularExpression(pattern: "^\\d+$") else {
            throw SessionError.RuntimeError("Could not create regular expression")
        }
        self.numericStringCheck = numericStringCheck

        super.init()

        let typeAsString = try? container.decodeIfPresent(String.self, forKey: .type)
        self.type = self.getFieldType(type: typeAsString)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(identifier, forKey: .id)
        try? container.encode(usedForLookup, forKey: .usedForLookup)
        try? container.encode(dataRestrictions, forKey: .dataRestrictions)
        try? container.encode(displayHints, forKey: .displayHints)
        try? container.encode(getFieldTypeString(type: type), forKey: .type)
    }

    private func getFieldType(type: String?) -> FieldType {
        switch type {
        case "string":
            return .string
        case "integer":
            return .integer
        case "expirydate":
            return .expirationDate
        case "numericstring":
            return .numericString
        case "boolean":
            return .boolString
        case "date":
            return .dateString
        default:
            Macros.DLog(message: "PaymentProductField type: \(type) is invalid")
            return .string
        }
    }

    private func getFieldTypeString(type: FieldType) -> String {
        switch type {
        case .string:
            return "string"
        case .integer:
            return "integer"
        case .expirationDate:
            return "expirydate"
        case .numericString:
            return "numericstring"
        case .boolString:
            return "boolean"
        case .dateString:
            return "date"
        }
    }

    @objc(validateValue:)
    public func validateValue(value: String) -> [ValidationError] {
        errors.removeAll()
        errorMessageIds.removeAll()

        if dataRestrictions.isRequired && value.isEqual("") {
            let error =
                ValidationErrorIsRequired(
                    errorMessage: "required",
                    paymentProductFieldId: identifier,
                    rule: nil
                )
            errors.append(error)
            errorMessageIds.append(error)
        } else if dataRestrictions.isRequired ||
                    !value.isEqual("") ||
                    dataRestrictions.validators.variableRequiredness {
            for rule in dataRestrictions.validators.validators {
                _ = rule.validate(value: value, for: identifier)
                errors.append(contentsOf: rule.errors)
                errorMessageIds.append(contentsOf: rule.errors)
            }
        }

        return errorMessageIds
    }

    @available(
        *,
        deprecated,
        message:
            """
            In a future release, this function will be removed.
            Please use validateValue(value:) or validateValue(for:) instead.
            """
    )
    @objc(validateValue:forPaymentRequest:)
    public func validateValue(value: String, for request: PaymentRequest) -> [ValidationError] {
        return validateValue(value: value)
    }

    @objc(validateValueforPaymentRequest:)
    public func validateValue(for request: PaymentRequest) -> [ValidationError] {
        guard let value = request.getValue(forField: identifier) else {
            return validateValue(value: "")
        }

        return validateValue(value: value)
    }

    @objc public func applyMask(value: String) -> String {
        if let mask = displayHints.mask {
            return stringFormatter.formatString(string: value, mask: mask)
        }

        return value
    }

    @objc public func removeMask(value: String) -> String {
        if let mask = displayHints.mask {
            return stringFormatter.unformatString(string: value, mask: mask)
        }

        return value
    }
}
