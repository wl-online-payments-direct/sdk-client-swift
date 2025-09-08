//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidatorExpirationDate)
public class ValidatorExpirationDate: Validator, ValidationRule {
    @objc public var dateFormatter = DateFormatter()
    private var fullYearDateFormatter = DateFormatter()
    private var monthAndFullYearDateFormatter = DateFormatter()

    internal override init() {
        dateFormatter.dateFormat = "MMyy"
        fullYearDateFormatter.dateFormat = "yyyy"
        monthAndFullYearDateFormatter.dateFormat = "MMyyyy"

        super.init(messageId: "expirationDate", validationType: .expirationDate)
    }

    // periphery:ignore:parameters decoder
    public required init(from decoder: Decoder) throws {
        dateFormatter.dateFormat = "MMyy"
        fullYearDateFormatter.dateFormat = "yyyy"
        monthAndFullYearDateFormatter.dateFormat = "MMyyyy"

        super.init(messageId: "expirationDate", validationType: .expirationDate)
    }

    @objc public func validate(field fieldId: String, in request: PaymentRequest) -> Bool {
        guard let fieldValue = request.getValue(forField: fieldId) else {
            return false
        }

        return validate(value: fieldValue, for: fieldId)
    }

    @objc public func validate(value: String) -> Bool {
        validate(value: value, for: nil)
    }

    internal override func validate(value: String, for fieldId: String?) -> Bool {
        self.clearErrors()

        // Test whether the date can be parsed normally
        if dateFormatter.date(from: value) == nil && monthAndFullYearDateFormatter.date(from: value) == nil
        {
            addExpirationDateError(fieldId: fieldId)
            return false
        }

        let enteredDate = obtainEnteredDateFromValue(value: value, fieldId: fieldId)

        guard let futureDate = obtainFutureDate() else {
            addExpirationDateError(fieldId: fieldId)
            return false
        }

        if !validateDateIsBetween(now: Date(), futureDate: futureDate, dateToValidate: enteredDate) {
            addExpirationDateError(fieldId: fieldId)
            return false
        }

        return true
    }

    private func addExpirationDateError(fieldId: String?) {
        let error =
            ValidationErrorExpirationDate(
                errorMessage: self.messageId,
                paymentProductFieldId: fieldId,
                rule: self
            )
        errors.append(error)
    }

    internal func obtainEnteredDateFromValue(value: String, fieldId: String?) -> Date {
        let year = fullYearDateFormatter.string(from: Date())
        let valueWithCentury = value.count == 6 ? value : value.substring(to: 2) + year.substring(to: 2) + value.substring(from: 2)
        guard let dateMonthAndFullYear = monthAndFullYearDateFormatter.date(from: valueWithCentury) else {
            addExpirationDateError(fieldId: fieldId)
            return Date()
        }

        return dateMonthAndFullYear
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
