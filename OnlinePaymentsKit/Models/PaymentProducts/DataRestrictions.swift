//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPDataRestrictions)
public class DataRestrictions: NSObject, Codable {

    @objc public var isRequired = false
    @objc public var validators = Validators()

    internal override init() {}

    private enum CodingKeys: String, CodingKey {
        case isRequired, validators, validationRules
    }

    private enum ValidationTypeKey: CodingKey {
        case validationType
    }

    public required init(from decoder: Decoder) throws {
        super.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let isRequired = try? container.decodeIfPresent(Bool.self, forKey: .isRequired) {
            self.isRequired = isRequired
        }

        if let validators = try? container.decodeIfPresent(Validators.self, forKey: .validators) {
            self.validators = validators
        } else if var validatorsContainer = try? container.nestedUnkeyedContainer(forKey: .validationRules) {
            setValidators(validatorsContainer: &validatorsContainer)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(isRequired, forKey: .isRequired)
        try? container.encode(validators.validators, forKey: .validationRules)
    }

    private func setValidators(validatorsContainer: inout UnkeyedDecodingContainer) {
        var validatorsArray = validatorsContainer
        while !validatorsContainer.isAtEnd {
            guard let validationRule = try? validatorsContainer.nestedContainer(keyedBy: ValidationTypeKey.self),
                  let typeString = try? validationRule.decodeIfPresent(String.self, forKey: .validationType) else {
                return
            }
            let validationType = getValidationType(type: typeString)
            addValidator(validatorType: validationType, validatorsArray: &validatorsArray)
        }
    }

    private func addValidator<T: Validator>(validatorType: T.Type, validatorsArray: inout UnkeyedDecodingContainer) {
        guard let validator = try? validatorsArray.decode(validatorType.self) else {
            return
        }
        self.validators.validators.append(validator)
    }

    // swiftlint:disable cyclomatic_complexity
    private func getValidationType(type: String) -> Validator.Type {
        switch type {
        case "EXPIRATIONDATE":
            return ValidatorExpirationDate.self
        case "EMAILADDRESS":
            return ValidatorEmailAddress.self
        case "FIXEDLIST":
            return ValidatorFixedList.self
        case "IBAN":
            return ValidatorIBAN.self
        case "LENGTH":
            return ValidatorLength.self
        case "LUHN":
            return ValidatorLuhn.self
        case "RANGE":
            return ValidatorRange.self
        case "REGULAREXPRESSION":
            return ValidatorRegularExpression.self
        case "TERMSANDCONDITIONS":
            return ValidatorTermsAndConditions.self
        case "REQUIRED", "TYPE":
            return Validator.self
        default:
            return Validator.self
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
