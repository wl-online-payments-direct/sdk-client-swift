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

class ValidationRuleFactoryTestCase: XCTestCase {

    var factory: ValidationRuleFactory!

    override func setUp() {
        super.setUp()
        factory = ValidationRuleFactory()
    }

    // MARK: - CSV Tests

    func testCreateRulesReturnsEmptyArrayWhenValidatorsDtoIsNil() {
        let rules = factory.createRules(from: nil)

        XCTAssertTrue(rules.isEmpty)
    }

    func testCreateRulesCreatesLuhnRuleWhenLuhnValidatorPresent() {
        let dto = ValidatorsDto(
            luhn: LuhnDto(),
            expirationDate: nil, range: nil, length: nil,
            fixedList: nil, emailAddress: nil,
            regularExpression: nil, termsAndConditions: nil, iban: nil
        )

        let rules = factory.createRules(from: dto)

        XCTAssertEqual(rules.count, 1)
        XCTAssertTrue(rules[0] is ValidatorLuhn)
    }

    func testCreateRulesCreatesIbanRuleWhenIbanValidatorPresent() {
        let dto = ValidatorsDto(
            luhn: nil, expirationDate: nil, range: nil, length: nil,
            fixedList: nil, emailAddress: nil,
            regularExpression: nil, termsAndConditions: nil,
            iban: IBANDto()
        )

        let rules = factory.createRules(from: dto)

        XCTAssertEqual(rules.count, 1)
        XCTAssertTrue(rules[0] is ValidatorIBAN)
    }

    func testCreateRulesCreatesTermsAndConditionsRuleWhenValidatorPresent() {
        let dto = ValidatorsDto(
            luhn: nil, expirationDate: nil, range: nil, length: nil,
            fixedList: nil, emailAddress: nil,
            regularExpression: nil,
            termsAndConditions: TermsAndConditionsDto(),
            iban: nil
        )

        let rules = factory.createRules(from: dto)

        XCTAssertEqual(rules.count, 1)
        XCTAssertTrue(rules[0] is ValidatorTermsAndConditions)
    }

    func testCreateRulesCreatesRegexRuleWithCorrectPatternWhenRegexValidatorPresent() {
        let pattern = "^[0-9]{4}$"
        let dto = ValidatorsDto(
            luhn: nil, expirationDate: nil, range: nil, length: nil,
            fixedList: nil, emailAddress: nil,
            regularExpression: RegularExpressionDto(regularExpression: pattern),
            termsAndConditions: nil, iban: nil
        )

        let rules = factory.createRules(from: dto)

        XCTAssertEqual(rules.count, 1)
        let regexRule = rules[0] as? ValidatorRegularExpression
        XCTAssertNotNil(regexRule)
        XCTAssertEqual(regexRule?.regularExpression.pattern, pattern)
    }

    func testCreateRulesCreatesEmailAddressRuleWhenValidatorPresent() {
        let dto = ValidatorsDto(
            luhn: nil, expirationDate: nil, range: nil, length: nil,
            fixedList: nil,
            emailAddress: EmailAddressDto(),
            regularExpression: nil, termsAndConditions: nil, iban: nil
        )

        let rules = factory.createRules(from: dto)

        XCTAssertEqual(rules.count, 1)
        XCTAssertTrue(rules[0] is ValidatorEmailAddress)
    }

    func testCreateRulesCreatesExpirationDateRuleWhenValidatorPresent() {
        let dto = ValidatorsDto(
            luhn: nil,
            expirationDate: ExpirationDateDto(),
            range: nil, length: nil,
            fixedList: nil, emailAddress: nil,
            regularExpression: nil, termsAndConditions: nil, iban: nil
        )

        let rules = factory.createRules(from: dto)

        XCTAssertEqual(rules.count, 1)
        XCTAssertTrue(rules[0] is ValidatorExpirationDate)
    }

    func testCreateRulesCreatesFixedListRuleWithCorrectValuesWhenValidatorPresent() {
        let allowed = ["visa", "mastercard"]
        let dto = ValidatorsDto(
            luhn: nil, expirationDate: nil, range: nil, length: nil,
            fixedList: FixedListDto(allowedValues: allowed),
            emailAddress: nil, regularExpression: nil, termsAndConditions: nil, iban: nil
        )

        let rules = factory.createRules(from: dto)

        XCTAssertEqual(rules.count, 1)
        let fixedListRule = rules[0] as? ValidatorFixedList
        XCTAssertNotNil(fixedListRule)
        XCTAssertEqual(fixedListRule?.allowedValues, allowed)
    }

    func testCreateRulesCreatesLengthRuleWithCorrectBoundsWhenValidatorPresent() {
        let dto = ValidatorsDto(
            luhn: nil, expirationDate: nil, range: nil,
            length: LengthDto(minLength: 2, maxLength: 10),
            fixedList: nil, emailAddress: nil,
            regularExpression: nil, termsAndConditions: nil, iban: nil
        )

        let rules = factory.createRules(from: dto)

        XCTAssertEqual(rules.count, 1)
        let lengthRule = rules[0] as? ValidatorLength
        XCTAssertNotNil(lengthRule)
        XCTAssertEqual(lengthRule?.minLength, 2)
        XCTAssertEqual(lengthRule?.maxLength, 10)
    }

    func testCreateRulesCreatesRangeRuleWithCorrectBoundsWhenValidatorPresent() {
        let dto = ValidatorsDto(
            luhn: nil, expirationDate: nil,
            range: RangeDto(minValue: 1, maxValue: 100),
            length: nil, fixedList: nil, emailAddress: nil,
            regularExpression: nil, termsAndConditions: nil, iban: nil
        )

        let rules = factory.createRules(from: dto)

        XCTAssertEqual(rules.count, 1)
        let rangeRule = rules[0] as? ValidatorRange
        XCTAssertNotNil(rangeRule)
        XCTAssertEqual(rangeRule?.minValue, 1)
        XCTAssertEqual(rangeRule?.maxValue, 100)
    }

    func testCreateRulesCreatesAllRulesWhenMultipleValidatorsPresent() {
        let dto = ValidatorsDto(
            luhn: LuhnDto(),
            expirationDate: ExpirationDateDto(),
            range: nil,
            length: LengthDto(minLength: 1, maxLength: 20),
            fixedList: nil, emailAddress: nil,
            regularExpression: nil, termsAndConditions: nil, iban: nil
        )

        let rules = factory.createRules(from: dto)

        XCTAssertEqual(rules.count, 3)
        XCTAssertTrue(rules.contains { $0 is ValidatorLuhn })
        XCTAssertTrue(rules.contains { $0 is ValidatorExpirationDate })
        XCTAssertTrue(rules.contains { $0 is ValidatorLength })
    }
}
