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

final class PaymentProductTests: XCTestCase {

    private var paymentProduct: PaymentProduct!

    override func setUp() {
        super.setUp()
        let dto = try! FixtureLoader.loadJSON(
            "cardPaymentProduct",
            as: PaymentProductDto.self
        )
        let factory = PaymentProductFactory()
        paymentProduct = factory.createPaymentProduct(from: dto)
    }

    func testGetFieldsShouldReturnCorrectLength() {
        let fields = paymentProduct.fields
        XCTAssertEqual(fields.count, 4)
    }

    func testGetFieldsShouldReturnCorrectElementsInAscendingOrder() {
        let fields = paymentProduct.fields
        let expectedIds = fields.map { $0.id }
        XCTAssertEqual(expectedIds, ["cardNumber", "cardholderName", "expiryDate", "cvv"])
    }

    func testGetRequiredFieldsShouldReturnCorrectLength() {
        let fields = paymentProduct.requiredFields
        XCTAssertEqual(fields.count, 3)
    }

    func testGetRequiredFieldsShouldReturnCorrectElements() {
        let fields = paymentProduct.requiredFields
        let expectedIds = fields.map { $0.id }
        XCTAssertEqual(expectedIds, ["cardNumber", "expiryDate", "cvv"])
    }

    func testGetFieldShouldReturnCardNumberField() {
        let field = paymentProduct.field(id: "cardNumber")
        XCTAssertNotNil(field)
        XCTAssertEqual(field?.id, "cardNumber")
    }

    func testGetFieldShouldReturnCvvField() {
        let field = paymentProduct.field(id: "cvv")
        XCTAssertNotNil(field)
        XCTAssertEqual(field?.id, "cvv")
    }

    func testGetFieldShouldReturnCardholderNameField() {
        let field = paymentProduct.field(id: "cardholderName")
        XCTAssertNotNil(field)
        XCTAssertEqual(field?.id, "cardholderName")
    }

    func testGetFieldShouldReturnExpiryDateField() {
        let field = paymentProduct.field(id: "expiryDate")
        XCTAssertNotNil(field)
        XCTAssertEqual(field?.id, "expiryDate")
    }

    func testGetFieldShouldReturnNilIfWrongId() {
        let field = paymentProduct.field(id: "123")
        XCTAssertNil(field)
    }

    func testApplyMaskOnField() {
        let maskedString =
            paymentProduct
            .field(id: "cardNumber")?
            .applyMask(value: "12345678901234567890")

        XCTAssertEqual(maskedString, "1234 5678 9012 3456 789")
    }

    func testValidateField() {
        let validationMessages =
            paymentProduct
            .field(id: "cardNumber")?
            .validate(value: "12345678901234567890")

        let types = validationMessages?.map { $0.type }
        XCTAssertEqual(types, ["LUHN", "LENGTH"])
    }

    func testIsRequiredField() {
        let isRequired =
            paymentProduct
            .field(id: "cardNumber")?
            .isRequired

        XCTAssertEqual(isRequired, true)
    }
}
