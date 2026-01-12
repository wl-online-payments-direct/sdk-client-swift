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

internal struct ValidatorsDto: Codable {
    let luhn: LuhnDto?
    let expirationDate: ExpirationDateDto?
    let range: RangeDto?
    let length: LengthDto?
    let fixedList: FixedListDto?
    let emailAddress: EmailAddressDto?
    let regularExpression: RegularExpressionDto?
    let termsAndConditions: TermsAndConditionsDto?
    let iban: IBANDto?
}
