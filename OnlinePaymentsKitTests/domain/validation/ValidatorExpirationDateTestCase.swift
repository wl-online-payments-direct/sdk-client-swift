/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import XCTest

@testable import OnlinePaymentsKit

final class ValidatorExpirationDateTestCase: XCTestCase {

    private let validator = ValidatorExpirationDate()

    func testValidateCorrectExpirationDates() {
        var result = validator.validate(value: "1244")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")

        result = validator.validate(value: "122044")
        XCTAssertTrue(result.valid)
        XCTAssertEqual(result.message, "")
    }

    func testRejectInvalidExpirationDateFormats() {
        var result = validator.validate(value: "aaaa")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Invalid expiration date format.")

        result = validator.validate(value: "12/44")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Invalid expiration date format.")

        result = validator.validate(value: "")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Invalid expiration date format.")

        result = validator.validate(value: "12ab")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Invalid expiration date format.")
    }

    func testRejectInvalidMonth() {
        let result = validator.validate(value: "1320")
        print("Valid: \(result.valid), Message: '\(result.message)'")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Invalid expiration date format.")
    }

    func testRejectPastExpirationDates() {
        var result = validator.validate(value: "0112")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Expiration date cannot be in the past.")

        result = validator.validate(value: "0123")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Expiration date cannot be in the past.")
    }

    func testRejectExpirationDatesTooFarInFuture() {
        var result = validator.validate(value: "1299")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Expiration date cannot be in the past.")

        result = validator.validate(value: "122055")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.message, "Expiration date cannot be in the past.")
    }

    func testValidateDateIsBetweenLowerBound() {
        let now = createDate(year: 2018, month: 9)
        let futureDate = createDate(year: 2033, month: 9)

        var testDate = createDate(year: 2018, month: 9)
        XCTAssertTrue(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))

        testDate = createDate(year: 2018, month: 8)
        XCTAssertFalse(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))

        testDate = createDate(year: 2017, month: 9)
        XCTAssertFalse(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }

    func testValidateDateIsBetweenUpperBound() {
        let now = createDate(year: 2018, month: 9)
        let futureDate = createDate(year: 2033, month: 9)

        var testDate = createDate(year: 2033, month: 9)
        XCTAssertTrue(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))

        testDate = createDate(year: 2033, month: 11)
        XCTAssertTrue(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))

        testDate = createDate(year: 2034, month: 1)
        XCTAssertFalse(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))

        testDate = createDate(year: 2099, month: 1)
        XCTAssertFalse(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }

    private func createDate(year: Int, month: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        return Calendar.current.date(from: components)!
    }
}
