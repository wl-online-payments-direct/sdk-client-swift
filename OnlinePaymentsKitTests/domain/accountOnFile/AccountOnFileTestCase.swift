/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation
import XCTest

@testable import OnlinePaymentsKit

final class AccountOnFileTests: XCTestCase {

    private var accountOnFile: AccountOnFile!

    override func setUp() {
        let dto = try! FixtureLoader.loadJSON(
            "accountOnFileVisa",
            as: AccountOnFileDto.self
        )
        let factory = PaymentProductFactory()
        accountOnFile = factory.createAccountOnFile(from: dto)
    }

    func testLabelShouldReturnLabelAlias() {
        XCTAssertEqual("4111 11XX XXXX 1111", accountOnFile.label)
    }

    func testIdShouldBe123() {
        XCTAssertEqual("123", accountOnFile.id)
    }

    func testPaymentProductIdShouldBe1() {
        XCTAssertEqual(1, accountOnFile.paymentProductId)
    }

    func testGetRequiredAttributesShouldReturnAttributesWithStatusMustWrite() {
        let requiredAttributes = accountOnFile.getRequiredAttributes()

        XCTAssertEqual(1, requiredAttributes.count)

        let first = requiredAttributes[0]
        XCTAssertEqual("cvv", first.key)
        XCTAssertEqual(AccountOnFileAttributeStatus.mustWrite, first.status)
        XCTAssertEqual("111", first.value)
    }

    func testIsWritableShouldReturnFalseForCardNumber() {
        XCTAssertFalse(accountOnFile.isWritable(id: "cardNumber"))
    }

    func testIsWritableShouldReturnTrueForCvv() {
        XCTAssertTrue(accountOnFile.isWritable(id: "cvv"))
    }

    func testGetValueShouldReturnMaskedCardNumberForCardNumber() {
        XCTAssertEqual(
            "411111XXXXXX1111",
            accountOnFile.getValue(id: "cardNumber")
        )
    }
}
