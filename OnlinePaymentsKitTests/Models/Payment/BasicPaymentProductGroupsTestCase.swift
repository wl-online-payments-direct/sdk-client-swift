//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class BasicPaymentProductGroupsTestCase: XCTestCase {
    let basicPaymentProductGroups = BasicPaymentProductGroups()

    override func setUp() {
        super.setUp()

        for index in 1..<6 {
            let basicPaymentProductGroup = BasicPaymentProductGroup(json: [
                "id": "\(index)",
                "displayHints": [
                    "displayOrder": 20,
                    "label": "Visa",
                    "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                ],
                "displayHintsList": [[
                    "displayOrder": 20,
                    "label": "Visa",
                    "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                ]],
                "accountsOnFile": [[
                    "id": index,
                    "paymentProductId": index
                    ]
                ]])!

            basicPaymentProductGroups.paymentProductGroups.append(basicPaymentProductGroup)
        }
        basicPaymentProductGroups.sort()
    }

    func testBasicPaymentProductGroupHasAccountOnFile() {
        XCTAssertTrue(basicPaymentProductGroups.hasAccountsOnFile, "BasicPaymentProductGroups has no accounts on file.")

        guard let paymentGroup = basicPaymentProductGroups.paymentProductGroups.first else {
            XCTFail("PaymentProductGroups array was empty.")
            return
        }

        let testAccountOnFile = AccountOnFile(json: ["id": 1, "paymentProductId": 1])!
        let foundAccountOnFile = paymentGroup.accountOnFile(withIdentifier: testAccountOnFile.identifier)
        XCTAssertTrue(foundAccountOnFile != nil, "Account on file identifier didn't match.")

        testAccountOnFile.identifier = "2"
        let didntFindAccountOnFile = paymentGroup.accountOnFile(withIdentifier: testAccountOnFile.identifier)
        XCTAssertTrue(didntFindAccountOnFile == nil, "Account on file identifier didn't match.")
    }

    func testFindProductGroupById() {
        let id = "2"
        let prodGroup = basicPaymentProductGroups.paymentProductGroup(withIdentifier: id)
        XCTAssertTrue(prodGroup != nil, "Product group with ID: \(id) was not found.")
    }

    func testPaymentGroup() {
        let foundGroup = basicPaymentProductGroups.paymentProductGroup(withIdentifier: "1")
        XCTAssertTrue(foundGroup != nil, "Group was not found.")

        let nonExistingGroup = basicPaymentProductGroups.paymentProductGroup(withIdentifier: "999")
        XCTAssertTrue(
            nonExistingGroup == nil,
            "Group was not suppose to be found: \(String(describing: nonExistingGroup))."
        )
    }

    func testLogoPath() {
        guard let group = basicPaymentProductGroups.paymentProductGroup(withIdentifier: "1") else {
            XCTFail("Did not find group.")
            return
        }
        group.displayHintsList = [PaymentItemDisplayHints(json: ["logo": "logoPath", "displayOrder": 0])!]

        XCTAssertTrue(basicPaymentProductGroups.logoPath(forProductGroup: "1") != nil, "Logo path was nil.")
        XCTAssertTrue(basicPaymentProductGroups.logoPath(forProductGroup: "999") == nil, "Logo path was not nil.")
    }
}
