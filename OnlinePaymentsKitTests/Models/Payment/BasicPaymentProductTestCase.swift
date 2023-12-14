//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class BasicPaymentProductTestCase: XCTestCase {

    var product: BasicPaymentProduct!
    let accountsOnFile = AccountsOnFile()
    var account1: AccountOnFile!
    var account2: AccountOnFile!

    override func setUp() {
        super.setUp()

        let account1JSON = Data("""
        {
            "id": 1,
            "paymentProductId": 1
        }
        """.utf8)

        let account2JSON = Data("""
        {
            "id": 2,
            "paymentProductId": 2
        }
        """.utf8)
        guard let account1 = try? JSONDecoder().decode(AccountOnFile.self, from: account1JSON),
              let account2 = try? JSONDecoder().decode(AccountOnFile.self, from: account2JSON) else {
            XCTFail("Accounts are not both a valid AccountOnFile")
            return
        }
        self.account1 = account1
        self.account2 = account2

        let productJSON = Data("""
        {
            "fields": [],
            "id": 1,
            "paymentMethod": "card",
            "displayHints": {
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            },
            "usesRedirectionTo3rdParty": false
        }
        """.utf8)
        guard let product = try? JSONDecoder().decode(BasicPaymentProduct.self, from: productJSON) else {
            XCTFail("Not a valid BasicPaymentProduct")
            return
        }
        self.product = product

        accountsOnFile.accountsOnFile.append(account1)
        accountsOnFile.accountsOnFile.append(account2)
        product.accountsOnFile = accountsOnFile
    }

    func testAccountOnFileWithIdentifier() {
        XCTAssert(product.accountOnFile(withIdentifier: "1") === account1, "Unexpected account on file retrieved")
    }

    func testSameBasicPaymentProduct() {
        let sameProduct = BasicPaymentProduct(json: [
            "fields": [[:]],
            "id": 1,
            "paymentMethod": "card",
            "displayHints": [
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            ],
            "usesRedirectionTo3rdParty": false
        ])!

        XCTAssertTrue(product == sameProduct)
        XCTAssertTrue(product.isEqual(sameProduct))
    }

    func testOtherBasicPaymentProduct() {
        let otherProduct = BasicPaymentProduct(json: [
            "fields": [[:]],
            "id": 2,
            "paymentMethod": "card",
            "displayHints": [
                "displayOrder": 21,
                "label": "MasterCard",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_2_v1.png"
            ],
            "usesRedirectionTo3rdParty": false
        ])!

        XCTAssertFalse(product == otherProduct)
        XCTAssertFalse(product.isEqual(otherProduct))
    }
}
