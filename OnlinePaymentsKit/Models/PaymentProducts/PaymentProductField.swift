//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2025 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentProductField)
public class PaymentProductField: NSObject, Codable {

    @objc public var identifier: String
    @objc public var dataRestrictions = DataRestrictions()
    @objc public var displayHints: PaymentProductFieldDisplayHints
    @objc public var type: FieldType = .string

    private var numberFormatter = NumberFormatter()
    private var numericStringCheck: NSRegularExpression

    @objc public var errorMessageIds: [ValidationError] = []

    private let stringFormatter = StringFormatter()

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
            let typeDescription = type ?? "nil"
            Logger.log("PaymentProductField type: \(typeDescription) is invalid")
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
        errorMessageIds.removeAll()

        if dataRestrictions.isRequired && value.isEqual("") {
            let error =
                ValidationErrorIsRequired(
                    errorMessage: "required",
                    paymentProductFieldId: identifier,
                    rule: nil
                )
            errorMessageIds.append(error)
        } else if dataRestrictions.isRequired ||
                    !value.isEqual("") ||
                    dataRestrictions.validators.variableRequiredness {
            for rule in dataRestrictions.validators.validators {
                _ = rule.validate(value: value, for: identifier)
                errorMessageIds.append(contentsOf: rule.errors)
            }
        }

        return errorMessageIds
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
