//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPValidator)
public class Validator: NSObject, Codable {
    @objc public var errors: [ValidationError] = []
    @objc public var messageId: String = ""
    @objc public var validationType: ValidationType = .type

    internal func validate(value: String, for fieldId: String?) -> Bool {
        clearErrors()

        return true
    }

    internal func clearErrors() {
        errors.removeAll()
    }

    internal override init() {
        super.init()
    }

    internal init(messageId: String, validationType: ValidationType) {
        self.messageId = messageId
        self.validationType = validationType
    }

    private enum CodingKeys: String, CodingKey {
        case messageId, validationType
    }

    public required init(from decoder: Decoder) throws {}

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(messageId, forKey: .messageId)
        try container.encodeIfPresent(getValidationTypeString(type: validationType), forKey: .validationType)
    }

    // swiftlint:disable cyclomatic_complexity
    private func getValidationTypeString(type: ValidationType) -> String {
        switch type {
        case .expirationDate:
            return "EXPIRATIONDATE"
        case .emailAddress:
            return "EMAILADDRESS"
        case .fixedList:
            return "FIXEDLIST"
        case .iban:
            return "IBAN"
        case .length:
            return "LENGTH"
        case .luhn:
            return "LUHN"
        case .range:
            return "RANGE"
        case .regularExpression:
            return "REGULAREXPRESSION"
        case .required:
            return "REQUIRED"
        case .type:
            return "TYPE"
        case .termsAndConditions:
            return "TERMSANDCONDITIONS"
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
