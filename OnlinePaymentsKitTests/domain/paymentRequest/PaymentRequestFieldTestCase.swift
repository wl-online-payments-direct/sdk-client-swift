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

final class PaymentRequestFieldTests: XCTestCase {

    private var paymentRequestField: PaymentRequestField!

    override func setUp() {
        super.setUp()

        let dto = try! FixtureLoader.loadJSON(
            "paymentProductFieldCard",
            as: PaymentProductFieldDto.self
        )
        let factory = PaymentProductFactory()
        let definition = factory.createPaymentProductField(from: dto)

        paymentRequestField = PaymentRequestField(definition: definition, readOnly: false)
    }

    func testSetValueAndValueShouldWorkCorrectly() throws {
        try paymentRequestField.setValue(value: "1234 5678 9012 3456 789")
        let value = paymentRequestField.value

        XCTAssertEqual(value, "1234567890123456789")
    }

    func testValueShouldReturnNilWhenNoValueSet() {
        let value = paymentRequestField.value
        XCTAssertNil(value)
    }

    func testSetValueWithEmptyStringShouldSetValueToNil() throws {
        try paymentRequestField.setValue(value: "")
        let value = paymentRequestField.value

        XCTAssertNil(value)
    }

    func testClearValueShouldSetValueToNil() {
        paymentRequestField.clearValue()
        let value = paymentRequestField.value

        XCTAssertNil(value)
    }

    func testTypeShouldReturnNumericString() {
        XCTAssertEqual(paymentRequestField.type, .numericString)
    }

    func testShouldObfuscateShouldReturnTrue() {
        XCTAssertTrue(paymentRequestField.shouldObfuscate)
    }

    func testIsRequiredShouldReturnTrue() {
        XCTAssertTrue(paymentRequestField.isRequired)
    }

    func testMaskedValueShouldReturnMaskedValueAndNotAlterValue() throws {
        try paymentRequestField.setValue(value: "1234567890123456789")

        XCTAssertEqual(paymentRequestField.maskedValue, "1234 5678 9012 3456 789")
        XCTAssertEqual(paymentRequestField.value, "1234567890123456789")
    }

    func testFormatForDisplayShouldReturnMaskedValueButNotAlterFieldValue() throws {
        try paymentRequestField.setValue(value: "1234567890123456789")

        XCTAssertEqual(
            paymentRequestField.formatForDisplay(value: "1234567890123456789"),
            "1234 5678 9012 3456 789"
        )
        XCTAssertEqual(paymentRequestField.value, "1234567890123456789")
    }

    func testIdShouldReturnCardNumber() {
        XCTAssertEqual(paymentRequestField.id, "cardNumber")
    }

    func testLabelShouldReturnCardNumber() {
        XCTAssertEqual(paymentRequestField.label, "Card number")
    }

    //    func testPlaceholderShouldReturnTestPlaceholder() {
    //        XCTAssertEqual(paymentRequestField.placeholder, "Test placeholder")
    //    }

    func testValidateShouldReturnErrorsIfRequiredAndValueNotProvided() {
        let validationResult = paymentRequestField.validate()

        XCTAssertFalse(validationResult.isValid)
        XCTAssertEqual(validationResult.errors.count, 1)
    }

    func testValidateShouldReturnNoErrorsAndIsValidTrueWhenCorrectCardNumberPassed() throws {
        try paymentRequestField.setValue(value: "7822551678890142249")
        let validationResult = paymentRequestField.validate()

        XCTAssertTrue(validationResult.isValid)
        XCTAssertEqual(validationResult.errors.count, 0)
    }

    //    func testSetValueShouldThrowCorrectErrorMessageForReadOnlyField() {
    //        let definition = try! FixtureLoader.loadJSON(
    //            "paymentProductFieldCard",
    //            as: PaymentProductField.self
    //        )
    //
    //        let readOnlyField = PaymentRequestField(definition: definition, readOnly: true)
    //
    //        XCTAssertThrowsError(try readOnlyField.setValue(value: "4222422242224222")) { error in
    //            let err = error as? InvalidArgumentException
    //            XCTAssertNotNil(err)
    //            XCTAssertEqual(err?.message, "Cannot write \"READ_ONLY\" field: cardNumber")
    //        }
    //    }
}
