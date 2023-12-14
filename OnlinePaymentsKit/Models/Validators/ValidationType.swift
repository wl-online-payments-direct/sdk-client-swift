//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 26/09/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPValidationType)
public enum ValidationType: Int {
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
}
