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

final class PaymentProductFactoryTestCase: XCTestCase {

    private var factory: PaymentProductFactory!

    override func setUp() {
        super.setUp()
        factory = PaymentProductFactory()
    }

    override func tearDown() {
        factory = nil
        super.tearDown()
    }

    // MARK: - BasicPaymentProducts Tests

    func testCreateBasicPaymentProducts_WithValidDto_ShouldReturnBasicPaymentProducts() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("basicPaymentProducts", as: BasicPaymentProductsDto.self)

        // When
        let result = factory.createBasicPaymentProducts(from: dto)

        // Then
        XCTAssertNotNil(result)
        XCTAssertFalse(result!.paymentProducts.isEmpty)
        XCTAssertGreaterThan(result!.paymentProducts.count, 0)
    }

    func testCreateBasicPaymentProducts_WithNilDto_ShouldReturnNil() {
        // When
        let result = factory.createBasicPaymentProducts(from: nil)

        // Then
        XCTAssertNil(result)
    }

    func testCreateBasicPaymentProducts_WithEmptyProducts_ShouldReturnEmptyList() {
        // Given
        let dto = BasicPaymentProductsDto(paymentProducts: [])

        // When
        let result = factory.createBasicPaymentProducts(from: dto)

        // Then
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.paymentProducts.isEmpty)
    }

    func testCreateBasicPaymentProducts_WithNullProductsList_ShouldReturnEmptyList() {
        // Given
        let dto = BasicPaymentProductsDto(paymentProducts: nil)

        // When
        let result = factory.createBasicPaymentProducts(from: dto)

        // Then
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.paymentProducts.isEmpty)
    }

    // MARK: - BasicPaymentProduct Tests

    func testCreateBasicPaymentProduct_WithValidDto_ShouldReturnBasicPaymentProduct() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("basicPaymentProduct", as: BasicPaymentProductDto.self)

        // When
        let result = factory.createBasicPaymentProduct(from: dto)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, 0)
        XCTAssertEqual(result.label, "VISA")
        XCTAssertEqual(result.logo, "test-logo")
        XCTAssertEqual(result.displayOrder, 0)
        XCTAssertFalse(result.allowsTokenization)
        XCTAssertFalse(result.allowsRecurring)
        XCTAssertFalse(result.usesRedirectionTo3rdParty)
        XCTAssertEqual(result.accountsOnFile.count, 2)
    }

    func testCreateBasicPaymentProduct_WithNullableId_ShouldHandleNullId() {
        // Given
        let dto = BasicPaymentProductDto(
            id: nil,
            paymentMethod: "card",
            displayHints: nil,
            accountsOnFile: nil,
            allowsRecurring: nil,
            allowsTokenization: nil,
            maxAmount: nil,
            minAmount: nil,
            usesRedirectionTo3rdParty: nil,
            paymentProduct302SpecificData: nil,
            paymentProduct320SpecificData: nil,
            paymentProductGroup: nil
        )

        // When
        let result = factory.createBasicPaymentProduct(from: dto)

        // Then
        XCTAssertNil(result.id)
        XCTAssertNil(result.label)
        XCTAssertNil(result.logo)
        XCTAssertEqual(result.displayOrder, Int.max)
        XCTAssertFalse(result.allowsTokenization)
        XCTAssertFalse(result.allowsRecurring)
        XCTAssertFalse(result.usesRedirectionTo3rdParty)
    }

    func testCreateBasicPaymentProduct_WithMissingDisplayHints_ShouldUseDefaults() {
        // Given
        let dto = BasicPaymentProductDto(
            id: 123,
            paymentMethod: "card",
            displayHints: nil,
            accountsOnFile: nil,
            allowsRecurring: nil,
            allowsTokenization: nil,
            maxAmount: nil,
            minAmount: nil,
            usesRedirectionTo3rdParty: nil,
            paymentProduct302SpecificData: nil,
            paymentProduct320SpecificData: nil,
            paymentProductGroup: nil
        )

        // When
        let result = factory.createBasicPaymentProduct(from: dto)

        // Then
        XCTAssertNil(result.label)
        XCTAssertNil(result.logo)
        XCTAssertEqual(result.displayOrder, Int.max)
    }

    func testCreateBasicPaymentProduct_WithSpecificData_ShouldIncludeSpecificData() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("basicPaymentProduct", as: BasicPaymentProductDto.self)

        // When
        let result = factory.createBasicPaymentProduct(from: dto)

        // Then
        XCTAssertNotNil(result.paymentProduct302SpecificData)
        XCTAssertNotNil(result.paymentProduct320SpecificData)
        XCTAssertEqual(result.paymentProduct302SpecificData?.networks.count, 3)
        XCTAssertEqual(result.paymentProduct320SpecificData?.networks.count, 3)
        XCTAssertEqual(result.paymentProduct320SpecificData?.gateway, "test gateway")
    }

    // MARK: - PaymentProduct Tests

    func testCreatePaymentProduct_WithValidDto_ShouldReturnPaymentProduct() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("cardPaymentProduct", as: PaymentProductDto.self)

        // When
        let result = factory.createPaymentProduct(from: dto)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.label, "VISA")
        XCTAssertEqual(result.logo, "test-logo")
        XCTAssertTrue(result.allowsTokenization)
        XCTAssertTrue(result.allowsRecurring)
        XCTAssertFalse(result.fields.isEmpty)
        XCTAssertEqual(result.fields.count, 4)
    }

    func testCreatePaymentProduct_WithFields_ShouldSortByDisplayOrder() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("cardPaymentProduct", as: PaymentProductDto.self)

        // When
        let result = factory.createPaymentProduct(from: dto)

        // Then
        XCTAssertEqual(result.fields[0].id, "cardNumber")
        XCTAssertEqual(result.fields[0].displayHints.displayOrder, 0)
        XCTAssertEqual(result.fields[1].id, "cardholderName")
        XCTAssertEqual(result.fields[1].displayHints.displayOrder, 1)
        XCTAssertEqual(result.fields[2].id, "expiryDate")
        XCTAssertEqual(result.fields[2].displayHints.displayOrder, 2)
        XCTAssertEqual(result.fields[3].id, "cvv")
        XCTAssertEqual(result.fields[3].displayHints.displayOrder, 3)
    }

    func testCreatePaymentProduct_WithRequiredFields_ShouldIdentifyRequiredFields() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("cardPaymentProduct", as: PaymentProductDto.self)

        // When
        let result = factory.createPaymentProduct(from: dto)

        // Then
        let requiredFields = result.requiredFields
        XCTAssertEqual(requiredFields.count, 2) // cardNumber and expiryDate are required
        XCTAssertTrue(requiredFields.contains { $0.id == "cardNumber" })
        XCTAssertTrue(requiredFields.contains { $0.id == "expiryDate" })
    }

    func testCreatePaymentProduct_ShouldInheritFromBasicPaymentProduct() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("cardPaymentProduct", as: PaymentProductDto.self)

        // When
        let result = factory.createPaymentProduct(from: dto)

        // Then
        XCTAssertTrue(result is BasicPaymentProduct)
        XCTAssertEqual(result.paymentMethod, "card")
    }

    // MARK: - PaymentProductField Tests

    func testCreatePaymentProductField_WithValidDto_ShouldReturnField() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("paymentProductFieldCard", as: PaymentProductFieldDto.self)

        // When
        let result = factory.createPaymentProductField(from: dto)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, "cardNumber")
        XCTAssertEqual(result.type, .numericString)
    }

    func testCreatePaymentProductField_WithDisplayHints_ShouldIncludeDisplayHints() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("paymentProductFieldCard", as: PaymentProductFieldDto.self)

        // When
        let result = factory.createPaymentProductField(from: dto)

        // Then
        XCTAssertNotNil(result.displayHints)
        XCTAssertEqual(result.displayHints.label, "Card number")
        XCTAssertEqual(result.displayHints.mask, "{{9999}} {{9999}} {{9999}} {{9999}}")
        XCTAssertFalse(result.displayHints.obfuscate)
        XCTAssertFalse(result.displayHints.alwaysShow)
    }

    func testCreatePaymentProductField_WithTooltip_ShouldIncludeTooltip() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("cardPaymentProduct", as: PaymentProductDto.self)
        let cvvFieldDto = dto.fields?.first { $0.id == "cvv" }

        // When
        let result = factory.createPaymentProductField(from: cvvFieldDto!)

        // Then
        XCTAssertNotNil(result.displayHints.tooltip)
        XCTAssertEqual(result.displayHints.tooltip?.label, "Last 3 digits on the back of the card")
    }

    func testCreatePaymentProductField_WithoutMask_ShouldHaveNilMask() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("paymentProductFieldWithoutMask", as: PaymentProductFieldDto.self)

        // When
        let result = factory.createPaymentProductField(from: dto)

        // Then
        XCTAssertNil(result.displayHints.mask)
    }

    func testCreatePaymentProductField_WithFormElement_ShouldIncludeFormElement() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("paymentProductFieldCard", as: PaymentProductFieldDto.self)

        // When
        let result = factory.createPaymentProductField(from: dto)

        // Then
        XCTAssertNotNil(result.displayHints.formElement)
        XCTAssertEqual(result.displayHints.formElement.type, .textType)
    }

    // MARK: - DataRestrictions Tests

    func testCreateDataRestrictions_WithRequired_ShouldSetIsRequired() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("dataRestrictionsRequired", as: DataRestrictionsDto.self)

        // When
        let result = factory.createDataRestrictions(from: dto)

        // Then
        XCTAssertTrue(result.isRequired)
    }

    func testCreateDataRestrictions_WithNotRequired_ShouldSetIsNotRequired() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("dataRestrictionsNotRequired", as: DataRestrictionsDto.self)

        // When
        let result = factory.createDataRestrictions(from: dto)

        // Then
        XCTAssertFalse(result.isRequired)
    }

    func testCreateDataRestrictions_WithNilDto_ShouldReturnDefaultFalse() {
        // When
        let result = factory.createDataRestrictions(from: nil)

        // Then
        XCTAssertFalse(result.isRequired)
        XCTAssertTrue(result.validationRules.isEmpty)
    }

    func testCreateDataRestrictions_WithValidators_ShouldIncludeValidationRules() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("dataRestrictionsRequired", as: DataRestrictionsDto.self)

        // When
        let result = factory.createDataRestrictions(from: dto)

        // Then
        XCTAssertFalse(result.validationRules.isEmpty)
    }

    // MARK: - AccountOnFile Tests

    func testCreateAccountOnFile_WithValidDto_ShouldReturnAccountOnFile() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("accountOnFileVisa", as: AccountOnFileDto.self)

        // When
        let result = factory.createAccountOnFile(from: dto)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, "test-1")
        XCTAssertEqual(result.paymentProductId, 1)
    }

    func testCreateAccountOnFile_WithAttributes_ShouldIncludeAttributes() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("accountOnFileVisa", as: AccountOnFileDto.self)

        // When
        let result = factory.createAccountOnFile(from: dto)

        // Then
        XCTAssertFalse(result.attributes.isEmpty)
        XCTAssertNotNil(result.getValue(id: "cardNumber"))
    }

    func testCreateAccountOnFile_WithLabel_ShouldCalculateLabel() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("accountOnFileVisa", as: AccountOnFileDto.self)

        // When
        let result = factory.createAccountOnFile(from: dto)

        // Then
        XCTAssertNotNil(result.label)
    }

    func testCreateAccountOnFile_WithMustWriteAttribute_ShouldIdentifyWritable() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("accountOnFileVisa", as: AccountOnFileDto.self)

        // When
        let result = factory.createAccountOnFile(from: dto)

        // Then
        XCTAssertTrue(result.isWritable(id: "cvv"))
        XCTAssertFalse(result.isWritable(id: "cardNumber"))
    }

    func testCreateAccountsOnFile_WithFilterByProductId_ShouldFilterCorrectly() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("basicPaymentProduct", as: BasicPaymentProductDto.self)

        // When
        let result = factory.createBasicPaymentProduct(from: dto)

        // Then
        // All accounts should have paymentProductId matching the product id
        XCTAssertEqual(result.accountsOnFile.count, 2)
        result.accountsOnFile.forEach { account in
            XCTAssertEqual(account.paymentProductId, result.id)
        }
    }

    func testCreateAccountsOnFile_WithNilProductId_ShouldIncludeAllAccounts() {
        // Given
        let accountDto1 = AccountOnFileDto(
            id: "1",
            paymentProductId: 1,
            attributes: nil,
            displayHints: nil
        )
        let accountDto2 = AccountOnFileDto(
            id: "2",
            paymentProductId: 2,
            attributes: nil,
            displayHints: nil
        )

        let dto = BasicPaymentProductDto(
            id: nil,
            paymentMethod: "card",
            displayHints: nil,
            accountsOnFile: [accountDto1, accountDto2],
            allowsRecurring: nil,
            allowsTokenization: nil,
            maxAmount: nil,
            minAmount: nil,
            usesRedirectionTo3rdParty: nil,
            paymentProduct302SpecificData: nil,
            paymentProduct320SpecificData: nil,
            paymentProductGroup: nil
        )

        // When
        let result = factory.createBasicPaymentProduct(from: dto)

        // Then
        // With nil productId, all accounts should be included (no filtering)
        XCTAssertEqual(result.accountsOnFile.count, 2)
    }

    // MARK: - Edge Cases

    func testCreatePaymentProduct_WithNilFields_ShouldReturnEmptyFieldsList() {
        // Given
        let dto = PaymentProductDto(
            id: 1,
            paymentMethod: "card",
            displayHints: nil,
            accountsOnFile: nil,
            allowsRecurring: nil,
            allowsTokenization: nil,
            maxAmount: nil,
            minAmount: nil,
            usesRedirectionTo3rdParty: nil,
            paymentProduct302SpecificData: nil,
            paymentProduct320SpecificData: nil,
            paymentProductGroup: nil,
            fields: nil
        )

        // When
        let result = factory.createPaymentProduct(from: dto)

        // Then
        XCTAssertTrue(result.fields.isEmpty)
    }

    func testCreatePaymentProduct_WithEmptyFields_ShouldReturnEmptyFieldsList() {
        // Given
        let dto = PaymentProductDto(
            id: 1,
            paymentMethod: "card",
            displayHints: nil,
            accountsOnFile: nil,
            allowsRecurring: nil,
            allowsTokenization: nil,
            maxAmount: nil,
            minAmount: nil,
            usesRedirectionTo3rdParty: nil,
            paymentProduct302SpecificData: nil,
            paymentProduct320SpecificData: nil,
            paymentProductGroup: nil,
            fields: []
        )

        // When
        let result = factory.createPaymentProduct(from: dto)

        // Then
        XCTAssertTrue(result.fields.isEmpty)
    }

    func testFieldLookup_ByIdentifier_ShouldReturnCorrectField() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("cardPaymentProduct", as: PaymentProductDto.self)
        let product = factory.createPaymentProduct(from: dto)

        // When
        let cardNumberField = product.field(id: "cardNumber")
        let cvvField = product.field(id: "cvv")
        let nonExistentField = product.field(id: "nonexistent")

        // Then
        XCTAssertNotNil(cardNumberField)
        XCTAssertEqual(cardNumberField?.id, "cardNumber")
        XCTAssertNotNil(cvvField)
        XCTAssertEqual(cvvField?.id, "cvv")
        XCTAssertNil(nonExistentField)
    }

    func testFieldType_Mapping_ShouldMapCorrectly() throws {
        // Given
        let dto = try FixtureLoader.loadJSON("cardPaymentProduct", as: PaymentProductDto.self)
        let product = factory.createPaymentProduct(from: dto)

        // When/Then
        let cardholderNameField = product.field(id: "cardholderName")
        XCTAssertEqual(cardholderNameField?.type, .string)

        let expiryDateField = product.field(id: "expiryDate")
        XCTAssertEqual(expiryDateField?.type, .expirationDate)

        let cvvField = product.field(id: "cvv")
        XCTAssertEqual(cvvField?.type, .numericString)

        let cardNumberField = product.field(id: "cardNumber")
        XCTAssertEqual(cardNumberField?.type, .numericString)
    }
}
