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

class PaymentProductFieldTestCase: XCTestCase {

    private var paymentProductField: PaymentProductField!

    override func setUp() {
        super.setUp()
        let dto = try! FixtureLoader.loadJSON(
            "paymentProductFieldCard",
            as: PaymentProductFieldDto.self
        )
        let factory = PaymentProductFactory()
        paymentProductField = factory.createPaymentProductField(from: dto)
    }

    func testGetLabelShouldReturnCardNumber() {
        let label = paymentProductField.label
        XCTAssertEqual("Card number", label)
    }

    func testGetTypeShouldReturnCardNumber() {
        let type = paymentProductField.type
        XCTAssertEqual(FieldType.numericString, type)
    }

    func testGetPlaceholderShouldReturnTestPlaceholder() {
        let placeholder = paymentProductField.placeholder
        XCTAssertEqual("Test placeholder", placeholder)
    }

    func testShouldObfuscateShouldReturnTrue() {
        let shouldObfuscate = paymentProductField.shouldObfuscate
        XCTAssertTrue(shouldObfuscate)
    }

    func testIsRequiredShouldReturnTrue() {
        let required = paymentProductField.isRequired
        XCTAssertTrue(required)
    }

    func testApplyMaskShouldReturnMaskedValue() {
        let maskedValue = paymentProductField.applyMask(value: "12345678901234567890")
        XCTAssertEqual("1234 5678 9012 3456 789", maskedValue)
    }

    func testApplyMaskShouldReturnUnmaskedValueIfNoMask() {
        let dto = try! FixtureLoader.loadJSON(
            "paymentProductFieldWithoutMask",
            as: PaymentProductFieldDto.self
        )
        let factory = PaymentProductFactory()
        let fieldWithoutMask = factory.createPaymentProductField(from: dto)

        let maskedValue = fieldWithoutMask.applyMask(value: "12345678901234567890")
        XCTAssertEqual("12345678901234567890", maskedValue)
    }

    func testRemoveMaskShouldReturnUnmaskedValue() {
        let mask = paymentProductField.applyMask(value: "1234567890123456789")
        XCTAssertEqual("1234 5678 9012 3456 789", mask)

        let rawValue = paymentProductField.removeMask(value: mask)
        XCTAssertEqual("1234567890123456789", rawValue)
    }

    func testValidateShouldReturnEmptyListOfErrorMessagesForValidInput() {
        let errorMessages = paymentProductField.validate(value: "4242424242424242")
        XCTAssertEqual(0, errorMessages.count)
    }

    func testValidateShouldReturnListWithErrorMessagesForInvalidInput() {
        let errorMessages = paymentProductField.validate(value: "424")
        print(errorMessages)
        XCTAssertEqual(2, errorMessages.count)

        print(errorMessages)

        XCTAssertEqual("Card number is in invalid format.", errorMessages[0].errorMessage)
        XCTAssertEqual("Provided value does not have an allowed length.", errorMessages[1].errorMessage)
    }

    func testValidateShouldReturnRequiredErrorWhenValueIsNilAndFieldIsRequired() {
        let errorMessages = paymentProductField.validate(value: nil)
        XCTAssertEqual(1, errorMessages.count)
        XCTAssertEqual("Field required.", errorMessages[0].errorMessage)
    }

    func testValidateShouldReturnRequiredErrorWhenValueIsEmptyAndFieldIsRequired() {
        let errorMessages = paymentProductField.validate(value: "")
        XCTAssertEqual(1, errorMessages.count)
        XCTAssertEqual("Field required.", errorMessages[0].errorMessage)
    }
}
