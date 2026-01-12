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

class BasicPaymentProductsTests: XCTestCase {

    private var basicPaymentProducts: BasicPaymentProducts!

    override func setUp() {
        super.setUp()

        let dto = try! FixtureLoader.loadJSON(
            "basicPaymentProducts",
            as: BasicPaymentProductsDto.self
        )
        let factory = PaymentProductFactory()
        basicPaymentProducts = factory.createBasicPaymentProducts(from: dto)
    }

    override func tearDown() {
        basicPaymentProducts = nil
        super.tearDown()
    }

    func testConstructorMapsPaymentProductsAndDeduplicatesAccountsOnFileById() {
        XCTAssertEqual(basicPaymentProducts.paymentProducts.count, 2)

        let accounts = basicPaymentProducts.accountsOnFile
        XCTAssertEqual(accounts.count, 1)

        let ids = Set(accounts.map { $0.id })
        XCTAssertEqual(ids, Set(["1234"]))
    }

    func testConstructorHandlesNullPaymentProducts() {
        let jsonString = """
            {
                "paymentProducts": null
            }
            """

        let jsonData = jsonString.data(using: .utf8)!

        let dto = try! JSONDecoder().decode(
            BasicPaymentProductsDto.self,
            from: jsonData
        )
        let factory = PaymentProductFactory()
        let emptyBasicPaymentProducts = factory.createBasicPaymentProducts(from: dto)!

        XCTAssertTrue(emptyBasicPaymentProducts.paymentProducts.isEmpty)
        XCTAssertTrue(emptyBasicPaymentProducts.accountsOnFile.isEmpty)
    }

    func testPaymentProductWithIdReturnsCorrectProduct() {
        let expectedId = 1

        let product = basicPaymentProducts.paymentProduct(withId: expectedId)

        XCTAssertNotNil(product)
        XCTAssertEqual(product?.id, expectedId)
    }

    func testPaymentProductWithIdReturnsNilForNonExistentId() {
        let product = basicPaymentProducts.paymentProduct(withId: 99999)

        XCTAssertNil(product)
    }

    func testAccountsOnFileDoesNotContainDuplicates() {
        let accounts = basicPaymentProducts.accountsOnFile

        let uniqueIds = Set(accounts.map { $0.id })

        XCTAssertEqual(accounts.count, uniqueIds.count, "Should not contain duplicate accounts")

        let account1234Count = accounts.filter { $0.id == "1234" }.count
        XCTAssertEqual(account1234Count, 1, "Account '1234' should appear only once despite being in JSON twice")
    }
}
