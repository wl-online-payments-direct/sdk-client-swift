//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidators)
public class Validators: NSObject, Decodable {
    @objc var variableRequiredness = false

    @objc public var validators = [Validator]()

    private enum CodingKeys: String, CodingKey {
        case luhn, expirationDate, range, length, fixedList, emailAddress, regularExpression, termsAndConditions, iban
    }

    internal override init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let validatorLuhn = try? container.decodeIfPresent(ValidatorLuhn.self, forKey: .luhn) {
            self.validators.append(validatorLuhn)
        }
        if let validatorExpirationDate =
            try? container.decodeIfPresent(ValidatorExpirationDate.self, forKey: .expirationDate) {
                self.validators.append(validatorExpirationDate)
        }
        if let validatorRange = try? container.decodeIfPresent(ValidatorRange.self, forKey: .range) {
            self.validators.append(validatorRange)
        }
        if let validatorLength = try? container.decodeIfPresent(ValidatorLength.self, forKey: .length) {
            self.validators.append(validatorLength)
        }
        if let validatorFixedList = try? container.decodeIfPresent(ValidatorFixedList.self, forKey: .fixedList) {
            self.validators.append(validatorFixedList)
        }
        if let validatorEmailAddress =
            try? container.decodeIfPresent(ValidatorEmailAddress.self, forKey: .emailAddress) {
                self.validators.append(validatorEmailAddress)
        }
        if let validatorRegularExpression =
            try? container.decodeIfPresent(ValidatorRegularExpression.self, forKey: .regularExpression) {
                self.validators.append(validatorRegularExpression)
        }
        if let validatorTermsAndConditions =
            try? container.decodeIfPresent(ValidatorTermsAndConditions.self, forKey: .termsAndConditions) {
                self.validators.append(validatorTermsAndConditions)
        }
        if let validatorIBAN = try? container.decodeIfPresent(ValidatorIBAN.self, forKey: .iban) {
            self.validators.append(validatorIBAN)
        }
    }
}
