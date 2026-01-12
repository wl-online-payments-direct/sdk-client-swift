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

internal class ValidationRuleFactory {
    func createRules(from validatorsDto: ValidatorsDto?) -> [ValidationRule] {
        guard let validatorsDto = validatorsDto else {
            return []
        }

        var rules: [ValidationRule] = []

        if validatorsDto.luhn != nil {
            rules.append(ValidatorLuhn())
        }

        if validatorsDto.iban != nil {
            rules.append(ValidatorIBAN())
        }

        if validatorsDto.termsAndConditions != nil {
            rules.append(ValidatorTermsAndConditions())
        }

        if let regularExpression = validatorsDto.regularExpression?.regularExpression,
            let regex = try? NSRegularExpression(pattern: regularExpression, options: [])
        {
            rules.append(ValidatorRegularExpression(regularExpression: regex))
        }

        if validatorsDto.emailAddress != nil {
            rules.append(ValidatorEmailAddress())
        }

        if validatorsDto.expirationDate != nil {
            rules.append(ValidatorExpirationDate())
        }

        if let allowedValues = validatorsDto.fixedList?.allowedValues {
            rules.append(ValidatorFixedList(allowedValues: allowedValues))
        }

        if let length = validatorsDto.length {
            rules.append(ValidatorLength(minLength: length.minLength, maxLength: length.maxLength))
        }

        if let range = validatorsDto.range {
            rules.append(ValidatorRange(minValue: range.minValue, maxValue: range.maxValue))
        }

        return rules
    }
}
