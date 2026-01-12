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

@objc(OPValidatorExpirationDate) public class ValidatorExpirationDate: NSObject, ValidationRule {
    @objc public let messageId: String = "expirationDate"
    @objc public let type: ValidationType = .expirationDate

    @objc public var dateFormatter = DateFormatter()
    private var fullYearDateFormatter = DateFormatter()
    private var monthAndFullYearDateFormatter = DateFormatter()

    internal override init() {
        dateFormatter.dateFormat = "MMyy"
        fullYearDateFormatter.dateFormat = "yyyy"
        monthAndFullYearDateFormatter.dateFormat = "MMyyyy"

        super.init()
    }

    @objc public func validate(value: String) -> RuleValidationResult {
        guard let enteredDate = obtainEnteredDateFromValue(value: value) else {
            return RuleValidationResult(
                valid: false,
                message: "Invalid expiration date format."
            )
        }

        if value.isEmpty {
            return RuleValidationResult(
                valid: false,
                message: "Invalid expiration date format."
            )
        }

        if dateFormatter.date(from: value) == nil && monthAndFullYearDateFormatter.date(from: value) == nil {
            return RuleValidationResult(
                valid: false,
                message: "Invalid expiration date format."
            )
        }

        guard let futureDate = obtainFutureDate() else {
            return RuleValidationResult(
                valid: false,
                message: "Unable to validate expiration date."
            )
        }

        if !validateDateIsBetween(now: Date(), futureDate: futureDate, dateToValidate: enteredDate) {
            return RuleValidationResult(
                valid: false,
                message: "Expiration date cannot be in the past."
            )
        }

        return RuleValidationResult(
            valid: true,
            message: ""
        )
    }

    internal func obtainEnteredDateFromValue(value: String) -> Date? {
        let year = fullYearDateFormatter.string(from: Date())
        let valueWithCentury =
            value.count == 6 ? value : value.substring(to: 2) + year.substring(to: 2) + value.substring(from: 2)
        //return nil when parse fails
        return monthAndFullYearDateFormatter.date(from: valueWithCentury)
    }

    private func obtainFutureDate() -> Date? {
        let gregorianCalendar = Calendar(identifier: .gregorian)

        var componentsForFutureDate = DateComponents()
        componentsForFutureDate.year = gregorianCalendar.component(.year, from: Date()) + 25

        return gregorianCalendar.date(from: componentsForFutureDate)
    }

    internal func validateDateIsBetween(now: Date, futureDate: Date, dateToValidate: Date) -> Bool {
        let gregorianCalendar = Calendar(identifier: .gregorian)

        let lowerBoundComparison = gregorianCalendar.compare(now, to: dateToValidate, toGranularity: .month)
        if lowerBoundComparison == ComparisonResult.orderedDescending {
            return false
        }

        let upperBoundComparison = gregorianCalendar.compare(futureDate, to: dateToValidate, toGranularity: .year)
        if upperBoundComparison == ComparisonResult.orderedAscending {
            return false
        }

        return true
    }
}
