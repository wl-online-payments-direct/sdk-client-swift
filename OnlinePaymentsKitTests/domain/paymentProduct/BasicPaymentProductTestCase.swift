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

final class BasicPaymentProductTests: XCTestCase {

    private var basicPaymentProduct: BasicPaymentProduct!

    override func setUp() {
        super.setUp()
        let dto = try! FixtureLoader.loadJSON(
            "basicPaymentProduct",
            as: BasicPaymentProductDto.self
        )
        let factory = PaymentProductFactory()
        basicPaymentProduct = factory.createBasicPaymentProduct(from: dto)
    }

    func testReturnLabelLogoAndDisplayOrder() {
        XCTAssertNotNil(basicPaymentProduct.logo)
        XCTAssertNotNil(basicPaymentProduct.label)
        XCTAssertNotEqual(basicPaymentProduct.displayOrder, Int.max)
        XCTAssertEqual(basicPaymentProduct.displayOrder, 0)
    }

    func testLabelShouldReturnTestLabel() {
        XCTAssertEqual("VISA", basicPaymentProduct.label)
    }

    func testLogoShouldReturnTestLogo() {
        XCTAssertEqual("test-logo", basicPaymentProduct.logo)
    }

    func testShouldReturnDisplayOrder() {
        XCTAssertEqual(0, basicPaymentProduct.displayOrder)
    }

    func testPaymentProduct302SpecificData_shouldNotBeNil() {
        XCTAssertNotNil(basicPaymentProduct.paymentProduct302SpecificData)
    }

    func testPaymentProduct320SpecificDataShouldNotBeNilAndValues() {
        let paymentProduct320SpecificData = basicPaymentProduct.paymentProduct320SpecificData
        XCTAssertNotNil(paymentProduct320SpecificData)
        XCTAssertEqual(
            ["test network 1", "test network 2", "test network 3"],
            paymentProduct320SpecificData?.networks
        )
        XCTAssertEqual("test gateway", paymentProduct320SpecificData?.gateway)
    }

    func testAccountsShouldReturnListOfAccountsWithLength2() {
        let accounts = basicPaymentProduct.accountsOnFile
        XCTAssertEqual(2, accounts.count)

        XCTAssertEqual("1234", accounts[0].id)
        XCTAssertEqual(0, accounts[0].paymentProductId)

        XCTAssertEqual("5678", accounts[1].id)
        XCTAssertEqual(0, accounts[1].paymentProductId)
    }

    func test_accountOnFileShouldReturnAccountOnFileForExistingId() {
        let accountOnFile = basicPaymentProduct.accountOnFile(withIdentifier: "5678")

        XCTAssertNotNil(accountOnFile)
        XCTAssertEqual("5678", accountOnFile?.id)
        XCTAssertEqual(0, accountOnFile?.paymentProductId)
    }

    func test_accountOnFileShouldReturnNilForNonExistingId() {
        let accountOnFile = basicPaymentProduct.accountOnFile(withIdentifier: "0")
        XCTAssertNil(accountOnFile)
    }
}
