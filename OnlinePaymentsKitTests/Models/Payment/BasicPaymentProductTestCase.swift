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
    var account: AccountOnFile!

    override func setUp() {
        super.setUp()

        let accountJSON = Data("""
        {
            "id": 1,
            "paymentProductId": 1
        }
        """.utf8)

        guard let account = try? JSONDecoder().decode(AccountOnFile.self, from: accountJSON) else {
            XCTFail("Accounts are not both a valid AccountOnFile")
            return
        }
        self.account = account

        let productJSON = Data("""
        {
            "fields": [],
            "id": 1,
            "paymentMethod": "card",
            "displayHintsList": [{
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            }],
            "usesRedirectionTo3rdParty": false
        }
        """.utf8)
        guard let product = try? JSONDecoder().decode(BasicPaymentProduct.self, from: productJSON) else {
            XCTFail("Not a valid BasicPaymentProduct")
            return
        }
        self.product = product

        accountsOnFile.accountsOnFile.append(account)
        product.accountsOnFile = accountsOnFile
    }

    func testAccountOnFileWithIdentifier() {
        XCTAssert(product.accountOnFile(withIdentifier: "1") === account, "Unexpected account on file retrieved")
    }

    func testSameBasicPaymentProduct() {
        guard let sameProduct = try? JSONDecoder().decode(BasicPaymentProduct.self, from: Data("""
            {
                "fields": [],
                "id": 1,
                "paymentMethod": "card",
                "displayHintsList": [{
                    "displayOrder": 20,
                    "label": "Visa",
                    "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                }],
                "usesRedirectionTo3rdParty": false
            }
            """.utf8)) else {
            XCTFail("Could not deserialize correct BasicPaymentProduct JSON")
            return
        }

        XCTAssertTrue(product == sameProduct)
        XCTAssertTrue(product.isEqual(sameProduct))
    }

    func testOtherBasicPaymentProduct() {
        guard let otherProduct = try? JSONDecoder().decode(BasicPaymentProduct.self, from: Data("""
            {
                "fields": [],
                "id": 2,
                "paymentMethod": "card",
                "displayHintsList": [{
                    "displayOrder": 21,
                    "label": "MasterCard",
                    "logo": "/templates/master/global/css/img/ppimages/pp_logo_2_v1.png"
                }],
                "usesRedirectionTo3rdParty": false
            }
            """.utf8)) else {
            XCTFail("Could not deserialize correct BasicPaymentProduct JSON")
            return
        }

        XCTAssertFalse(product == otherProduct)
        XCTAssertFalse(product.isEqual(otherProduct))
    }
}
