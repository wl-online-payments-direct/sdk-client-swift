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

class PaymentRequestTestCase: XCTestCase {

    private var paymentProduct: PaymentProduct!
    private var paymentRequest: PaymentRequest!
    private var accountOnFile: AccountOnFile!

    override func setUp() {
        super.setUp()

        let paymentProductDto = try! FixtureLoader.loadJSON(
            "cardPaymentProduct",
            as: PaymentProductDto.self
        )
        let factory = PaymentProductFactory()
        paymentProduct = factory.createPaymentProduct(from: paymentProductDto)

        let accountOnFileDto = try! FixtureLoader.loadJSON(
            "accountOnFileVisa",
            as: AccountOnFileDto.self
        )
        accountOnFile = factory.createAccountOnFile(from: accountOnFileDto)

        paymentRequest = PaymentRequest(paymentProduct: paymentProduct)
    }

    func testShouldReturnFieldForNonexistentFieldIdExpiryDate() {
        let field = try! paymentRequest.field(id: "expiryDate")

        XCTAssertEqual(FieldType.expirationDate, field.type)
        XCTAssertEqual("expiryDate", field.id)
    }

    func testShouldReturnCorrectLength() {
        let fieldExpiryDate = try! paymentRequest.field(id: "expiryDate")
        let fieldCvv = try! paymentRequest.field(id: "cvv")
        let fieldCardNumber = try! paymentRequest.field(id: "cardNumber")

        XCTAssertNil(fieldExpiryDate.value)
        XCTAssertNil(fieldCvv.value)
        XCTAssertNil(fieldCardNumber.value)

        try? fieldExpiryDate.setValue(value: "12-35")
        try? fieldCvv.setValue(value: "123")
        try? fieldCardNumber.setValue(value: "1234567890123456789")

        let fields = paymentRequest.values()

        XCTAssertEqual(3, fields.count)

        XCTAssertEqual("1235", paymentRequest.value(id: "expiryDate"))
        XCTAssertEqual("123", paymentRequest.value(id: "cvv"))
        XCTAssertEqual("1234567890123456789", paymentRequest.value(id: "cardNumber"))

        XCTAssertEqual("1235", fieldExpiryDate.value)
        XCTAssertEqual("123", fieldCvv.value)
        XCTAssertEqual("1234567890123456789", fieldCardNumber.value)
    }

    func testShouldGetValue123ForCvvFieldId() {
        let field = try! paymentRequest.field(id: "cvv")
        try? field.setValue(value: "123")

        let value = paymentRequest.value(id: "cvv")

        XCTAssertEqual("123", value)
    }

    func testShouldSetValue123ForCvvFieldId() {
        let field = try! paymentRequest.field(id: "cvv")

        XCTAssertNil(field.value)

        try? paymentRequest.setValue(id: "cvv", value: "123")
        let value = paymentRequest.value(id: "cvv")

        XCTAssertEqual("123", value)
    }

    func testShouldSetAndGetAccountOnFile() {
        XCTAssertNil(paymentRequest.accountOnFile)

        paymentRequest.setAccountOnFile(accountOnFile)

        XCTAssertNotNil(paymentRequest.accountOnFile)
        XCTAssertEqual("123", paymentRequest.accountOnFile?.id)
    }

    func testShouldSetAndGetTokenize() {
        XCTAssertFalse(paymentRequest.tokenize)

        paymentRequest.tokenize = true

        XCTAssertTrue(paymentRequest.tokenize)
    }

    func testShouldReturnNilWhenGetValueCalledForReadOnlyFields() {
        paymentRequest = PaymentRequest(paymentProduct: paymentProduct, accountOnFile: accountOnFile)

        XCTAssertNil(paymentRequest.value(id: "cardNumber"))
    }

    func testShouldRemoveFieldValuesAfterSettingAccountOnFileAndReturnNilIfReadOnly() {
        let paymentRequest = PaymentRequest(paymentProduct: paymentProduct)
        XCTAssertNil(paymentRequest.accountOnFile)

        let cardNumberField = try! paymentRequest.field(id: "cardNumber")
        try? cardNumberField.setValue(value: "1111111111")

        paymentRequest.setAccountOnFile(accountOnFile)

        XCTAssertThrowsError(try paymentRequest.field(id: "cardNumber").setValue(value: "2222222222"))

        XCTAssertNil(try! paymentRequest.field(id: "cardNumber").value)
        XCTAssertNotNil(paymentRequest.accountOnFile)
        XCTAssertEqual("123", paymentRequest.accountOnFile?.id)
    }

    func testShouldReturnErrorsForCvvCardNumberExpiryDateFieldRequiredIfNoAccountOnFileProvided() {
        paymentRequest = PaymentRequest(paymentProduct: paymentProduct)

        let validationResult = try! paymentRequest.validate()

        XCTAssertFalse(validationResult.isValid)
        XCTAssertEqual(3, validationResult.errors.count)
    }

    func testShouldReturnErrorsForCvvFieldRequiredIfAccountOnFileProvided() {
        paymentRequest.setAccountOnFile(accountOnFile)

        let validationResult = try! paymentRequest.validate()

        XCTAssertFalse(validationResult.isValid)
        XCTAssertEqual(1, validationResult.errors.count)
    }

    func testShouldReturnEmptyErrorsAndIsValidWhenAllFieldsSetCorrectly() {
        try? paymentRequest.setValue(id: "cardNumber", value: "7822551678890142249")
        try? paymentRequest.setValue(id: "expiryDate", value: "11/2026")
        try? paymentRequest.setValue(id: "cvv", value: "123")
        try? paymentRequest.setValue(id: "cardholderName", value: "test")

        let validationResult = try! paymentRequest.validate()

        XCTAssertTrue(validationResult.isValid)
        XCTAssertEqual(0, validationResult.errors.count)
    }
}
