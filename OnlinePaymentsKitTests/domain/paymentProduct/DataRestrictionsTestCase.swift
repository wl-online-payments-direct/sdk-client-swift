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

class DataRestrictionsTestCase: XCTestCase {

    func testIsRequiredReturnsTrueWhenIsRequiredIsTrueInJSON() {
        let dto = try! FixtureLoader.loadJSON(
            "dataRestrictionsRequired",
            as: DataRestrictionsDto.self
        )
        let factory = PaymentProductFactory()
        let dataRestrictions = factory.createDataRestrictions(from: dto)

        XCTAssertTrue(dataRestrictions.isRequired)
    }

    func testIsRequiredReturnsFalseWhenIsRequiredIsFalseInJSON() {
        let dto = try! FixtureLoader.loadJSON(
            "dataRestrictionsNotRequired",
            as: DataRestrictionsDto.self
        )
        let factory = PaymentProductFactory()
        let dataRestrictions = factory.createDataRestrictions(from: dto)

        XCTAssertFalse(dataRestrictions.isRequired)
    }

    func testValidationRulesIncludesValidationRuleLengthWhenLengthValidatorIsPresent() {
        let dto = try! FixtureLoader.loadJSON(
            "dataRestrictionsRequired",
            as: DataRestrictionsDto.self
        )
        let factory = PaymentProductFactory()
        let dataRestrictions = factory.createDataRestrictions(from: dto)

        let rules = dataRestrictions.validationRules

        XCTAssertEqual(1, rules.count)
        XCTAssertTrue(rules[0] is ValidatorLength)
    }

    func testValidationRulesIncludesMultipleValidatorsWhenBothLengthAndRegexArePresent() {
        let dto = try! FixtureLoader.loadJSON(
            "dataRestrictionsNotRequired",
            as: DataRestrictionsDto.self
        )
        let factory = PaymentProductFactory()
        let dataRestrictions = factory.createDataRestrictions(from: dto)

        let rules = dataRestrictions.validationRules

        XCTAssertEqual(2, rules.count)
        XCTAssertTrue(rules.contains(where: { $0 is ValidatorLength }))
        XCTAssertTrue(rules.contains(where: { $0 is ValidatorRegularExpression }))
    }

    func testValidationRulesAreCached() {
        let dto = try! FixtureLoader.loadJSON(
            "dataRestrictionsRequired",
            as: DataRestrictionsDto.self
        )
        let factory = PaymentProductFactory()
        let dataRestrictions = factory.createDataRestrictions(from: dto)

        let rules1 = dataRestrictions.validationRules
        let rules2 = dataRestrictions.validationRules

        XCTAssertTrue(rules1 as AnyObject === rules2 as AnyObject)
    }

    func testIsRequiredAndValidatorsWorkTogetherCorrectlyForRequiredFieldWithLength() {
        let dto = try! FixtureLoader.loadJSON(
            "dataRestrictionsRequired",
            as: DataRestrictionsDto.self
        )
        let factory = PaymentProductFactory()
        let dataRestrictions = factory.createDataRestrictions(from: dto)

        XCTAssertTrue(dataRestrictions.isRequired)
        XCTAssertEqual(1, dataRestrictions.validationRules.count)
        XCTAssertTrue(dataRestrictions.validationRules[0] is ValidatorLength)
    }

    func testIsRequiredAndValidatorsWorkTogetherCorrectlyForOptionalFieldWithMultipleValidators() {
        let dto = try! FixtureLoader.loadJSON(
            "dataRestrictionsNotRequired",
            as: DataRestrictionsDto.self
        )
        let factory = PaymentProductFactory()
        let dataRestrictions = factory.createDataRestrictions(from: dto)

        XCTAssertFalse(dataRestrictions.isRequired)
        XCTAssertEqual(2, dataRestrictions.validationRules.count)
    }
}
