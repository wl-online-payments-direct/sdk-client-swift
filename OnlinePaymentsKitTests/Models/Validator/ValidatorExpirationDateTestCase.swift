//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class ValidatorExpirationDateTestCase: XCTestCase {

    var validator: ValidatorExpirationDate!
    var request: PaymentRequest!

    override func setUp() {
        super.setUp()
        validator = ValidatorExpirationDate()

        let paymentProductJSON = Data("""
        {
            "fields": [
                {
                    "id": "expiryDate",
                    "type": "expirydate",
                    "displayHints": {
                        "displayOrder": 0,
                        "formElement": {
                            "type": "date"
                        }
                    }
                }
            ],
            "id": 1,
            "paymentMethod": "card",
            "displayHints": {
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            },
            "usesRedirectionTo3rdParty": false
        }
        """.utf8)

        guard let paymentProduct = try? JSONDecoder().decode(PaymentProduct.self, from: paymentProductJSON) else {
            XCTFail("Not a valid PaymentProduct")
            return
        }

        request = PaymentRequest(paymentProduct: paymentProduct)
    }

    func testValid() {
        request.setValue(forField: "expiryDate", value: "1244")
        _ = validator.validate(field: "expiryDate", in: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid expiration date considered invalid")
    }

    func testInvalidNonNumerical() {
        request.setValue(forField: "expiryDate", value: "aaaa")
        _ = validator.validate(field: "expiryDate", in: request)

        XCTAssertEqual(validator.errors.count, 1, "Invalid expiration date considered valid")
        XCTAssertEqual(validator.errors[0].errorMessage, "expirationDate")
        XCTAssertEqual(validator.errors[0].paymentProductFieldId, "expiryDate")
        XCTAssertEqual(validator.errors[0].rule?.type, .expirationDate)
    }

    func testInvalidMonth() {
        request.setValue(forField: "expiryDate", value: "1350")
        _ = validator.validate(field: "expiryDate", in: request)

        XCTAssertEqual(validator.errors.count, 1, "Invalid expiration date considered valid")
        XCTAssertEqual(validator.errors[0].errorMessage, "expirationDate")
        XCTAssertEqual(validator.errors[0].paymentProductFieldId, "expiryDate")
        XCTAssertEqual(validator.errors[0].rule?.type, .expirationDate)
    }

    func testInvalidYearTooEarly() {
        request.setValue(forField: "expiryDate", value: "0112")
        _ = validator.validate(field: "expiryDate", in: request)

        XCTAssertEqual(validator.errors.count, 1, "Invalid expiration date considered valid")
        XCTAssertEqual(validator.errors[0].errorMessage, "expirationDate")
        XCTAssertEqual(validator.errors[0].paymentProductFieldId, "expiryDate")
        XCTAssertEqual(validator.errors[0].rule?.type, .expirationDate)
    }

    func testInvalidYearTooLate() {
        request.setValue(forField: "expiryDate", value: "1299")
        _ = validator.validate(field: "expiryDate", in: request)

        XCTAssertEqual(validator.errors.count, 1, "Invalid expiration date considered valid")
        XCTAssertEqual(validator.errors[0].errorMessage, "expirationDate")
        XCTAssertEqual(validator.errors[0].paymentProductFieldId, "expiryDate")
        XCTAssertEqual(validator.errors[0].rule?.type, .expirationDate)
    }

    func testInvalidInputTooLong() {
        request.setValue(forField: "expiryDate", value: "122044")
        _ = validator.validate(field: "expiryDate", in: request)

        XCTAssertEqual(validator.errors.count, 1, "Invalid expiration date considered valid")
        XCTAssertEqual(validator.errors[0].errorMessage, "expirationDate")
        XCTAssertEqual(validator.errors[0].paymentProductFieldId, "expiryDate")
        XCTAssertEqual(validator.errors[0].rule?.type, .expirationDate)
    }

    private var now: Date {
        var components = DateComponents()
        components.year = 2018
        components.month = 9
        components.day = 23
        components.hour = 6
        components.minute = 33
        components.second = 37
        return Calendar.current.date(from: components)!
    }

    private var futureDate: Date {
        var components = DateComponents()
        components.year = 2033
        components.month = 9
        components.day = 23
        components.hour = 6
        components.minute = 33
        components.second = 37
        return Calendar.current.date(from: components)!
    }

    func testValidLowerSameMonthAndYear() {
        var components = DateComponents()
        components.year = 2018
        components.month = 9
        let testDate = Calendar.current.date(from: components)!

        XCTAssertTrue(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }

    func testInValidLowerMonth() {
        var components = DateComponents()
        components.year = 2018
        components.month = 8
        let testDate = Calendar.current.date(from: components)!

        XCTAssertFalse(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }

    func testInValidLowerYear() {
        var components = DateComponents()
        components.year = 2017
        components.month = 9
        let testDate = Calendar.current.date(from: components)!

        XCTAssertFalse(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }

    func testValidUpperSameMonthAndYear() {
        var components = DateComponents()
        components.year = 2033
        components.month = 9
        let testDate = Calendar.current.date(from: components)!

        XCTAssertTrue(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }

    func testValidUpperHigherMonthSameYear() {
        var components = DateComponents()
        components.year = 2033
        components.month = 11
        let testDate = Calendar.current.date(from: components)!

        XCTAssertTrue(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }

    func testInValidUpperHigherYear() {
        var components = DateComponents()
        components.year = 2034
        components.month = 1
        let testDate = Calendar.current.date(from: components)!

        XCTAssertFalse(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }

    func testInValidUpperMuchHigherYear() {
        var components = DateComponents()
        components.year = 2099
        components.month = 1
        let testDate = Calendar.current.date(from: components)!

        XCTAssertFalse(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }
}
