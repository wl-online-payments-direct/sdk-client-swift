//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class BasicPaymentProductTestCase: XCTestCase {

    let product = BasicPaymentProduct(json: [
        "fields": [[:]],
        "id": 1,
        "paymentMethod": "card",
        "displayHints": [
            "displayOrder": 20,
            "label": "Visa",
            "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
        ]
    ])!
    let accountsOnFile = AccountsOnFile()
    let account1 = AccountOnFile(json: ["id": 1, "paymentProductId": 1])!
    let account2 = AccountOnFile(json: ["id": 2, "paymentProductId": 2])!

    override func setUp() {
        super.setUp()

        accountsOnFile.accountsOnFile.append(account1)
        accountsOnFile.accountsOnFile.append(account2)
        product.accountsOnFile = accountsOnFile
    }

    func testAccountOnFileWithIdentifier() {
        XCTAssert(product.accountOnFile(withIdentifier: "1") === account1, "Unexpected account on file retrieved")
    }

}
