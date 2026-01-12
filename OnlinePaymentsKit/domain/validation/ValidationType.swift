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

@objc(OPValidationType) public enum ValidationType: Int {
    @objc(OPValidationTypeExpirationDate) case expirationDate
    @objc(OPValidationTypeEmailAddress) case emailAddress
    @objc(OPValidationTypeFixedList) case fixedList
    @objc(OPValidationTypeIBAN) case iban
    @objc(OPValidationTypeLength) case length
    @objc(OPValidationTypeLuhn) case luhn
    @objc(OPValidationTypeRange) case range
    @objc(OPValidationTypeRegularExpression) case regularExpression
    @objc(OPValidationTypeRequired) case required
    @objc(OPValidationTypeType) case type
    @objc(OPValidationTypeTermsAndConditions) case termsAndConditions

    public var stringValue: String {
        switch self {
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
}
