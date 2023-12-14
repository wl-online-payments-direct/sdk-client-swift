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
            let basicPaymentProductGroupDictionary = [
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
                ]]
            ] as [String: Any]

            guard let basicPaymentProductGroupJSON =
                    try? JSONSerialization.data(withJSONObject: basicPaymentProductGroupDictionary) else {
                XCTFail("Not a valid Dictionary")
                return
            }
            guard let basicPaymentProductGroup =
                    try? JSONDecoder().decode(BasicPaymentProductGroup.self, from: basicPaymentProductGroupJSON) else {
                XCTFail("Not a valid BasicPaymentProductGroup")
                return
            }

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

        let testAccountOnFileJSON = Data("""
        {
            "id": 1,
            "paymentProductId": 1
        }
        """.utf8)
        guard let testAccountOnFile = try? JSONDecoder().decode(AccountOnFile.self, from: testAccountOnFileJSON) else {
            XCTFail("Not a valid AccountOnFile")
            return
        }
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
        let displayHintsListJSON = Data("""
        [
            {
                "logo": "logoPath",
                "displayOrder": 0
            }
        ]
        """.utf8)

        guard let displayHintsList =
                try? JSONDecoder().decode([PaymentItemDisplayHints].self, from: displayHintsListJSON) else {
            XCTFail("Not a valid array of PaymentItemDisplayHints")
            return
        }
        group.displayHintsList = displayHintsList

        XCTAssertTrue(basicPaymentProductGroups.logoPath(forProductGroup: "1") != nil, "Logo path was nil.")
        XCTAssertTrue(basicPaymentProductGroups.logoPath(forProductGroup: "999") == nil, "Logo path was not nil.")
    }
}
