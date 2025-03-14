//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class AccountsOnFileTestCase: XCTestCase {

    let accountsOnFile = AccountsOnFile()
    var account1: AccountOnFile!
    var account2: AccountOnFile!

    override func setUp() {
        super.setUp()

        let account1JSON = Data("""
        {
            "id": "1",
            "paymentProductId": 1
        }
        """.utf8)

        let account2JSON = Data("""
        {
            "id": "2",
            "paymentProductId": 2
        }
        """.utf8)

        guard let account1 = try? JSONDecoder().decode(AccountOnFile.self, from: account1JSON),
              let account2 = try? JSONDecoder().decode(AccountOnFile.self, from: account2JSON) else {
            XCTFail("Accounts are not a valid AccountOnFile")
            return
        }

        self.account1 = account1
        self.account2 = account2

        accountsOnFile.accountsOnFile.append(self.account1)
        accountsOnFile.accountsOnFile.append(self.account2)
    }

    func testMaskedLabelWithMultipleLabelTemplateItems() {
        let testAccount = accountsOnFile.accountOnFile(withIdentifier: "1")
        XCTAssertNotNil(testAccount, "Account could not be found")
        XCTAssertEqual(testAccount!, account1, "Incorrect account on file retrieved")

        let attributeJSON = Data("""
        {
            "key": "expiryDate",
            "value" : "1224",
            "status" : "READ_ONLY"
        }
        """.utf8)

        let attributeJSON2 = Data("""
        {
            "key": "cardNumber",
            "value" : "4012XXXXXXXX0026",
            "status" : "READ_ONLY"
        }
        """.utf8)

        let attributeJSON3 = Data("""
        {
            "key": "alias",
            "value" : "4012XXXXXXXX0026",
            "status" : "READ_ONLY"
        }
        """.utf8)

        let labelTemplateItemJSON = Data("""
        {
            "attributeKey": "alias",
            "mask": "{{9999}} {{9999}} {{9999}} {{9999}}"
        }
        """.utf8)

        let labelTemplateItemJSON2 = Data("""
        {
            "attributeKey": "expiryDate",
            "mask": "{{99}}/{{99}}"
        }
        """.utf8)

        let labelTemplateItemJSON3 = Data("""
        {
            "attributeKey": "cardNumber",
            "mask": "{{9999}} {{9999}} {{9999}} {{9999}}"
        }
        """.utf8)

        guard let attribute = try? JSONDecoder().decode(AccountOnFileAttribute.self, from: attributeJSON),
              let attribute2 = try? JSONDecoder().decode(AccountOnFileAttribute.self, from: attributeJSON2),
              let attribute3 = try? JSONDecoder().decode(AccountOnFileAttribute.self, from: attributeJSON3) else {
                  XCTFail("Not a valid AccountOnFileAttribute")
                  return
        }

        guard let lti1 = try? JSONDecoder().decode(LabelTemplateItem.self, from: labelTemplateItemJSON),
              let lti2 = try? JSONDecoder().decode(LabelTemplateItem.self, from: labelTemplateItemJSON2),
              let lti3 = try? JSONDecoder().decode(LabelTemplateItem.self, from: labelTemplateItemJSON3) else {
                  XCTFail("Not a valid LabelTemplateItem")
                  return
        }

        testAccount?.displayHints.labelTemplate.labelTemplateItems.append(contentsOf: [lti1, lti2, lti3])
        testAccount?.attributes.attributes.append(contentsOf: [attribute, attribute2, attribute3])

        XCTAssertNotNil(testAccount?.hasValue(forField: "alias"))
        XCTAssertTrue(testAccount!.hasValue(forField: "alias"))
        XCTAssertEqual(testAccount?.label, "4012 XXXX XXXX 0026",
                      "Label not correct, label was \(String(describing: testAccount?.label))")
    }

    func testAccountOnFileWithIdentifier() {
        let testAccount = accountsOnFile.accountOnFile(withIdentifier: "1")

        XCTAssertNotNil(testAccount, "Account could not be found")
        XCTAssertEqual(testAccount, account1, "Incorrect account on file retrieved")

        for index in 0...3 {
            let templabelJSON = Data("""
            {
                "attributeKey": "attributeKey\(index)",
                "mask": "12345\(index)"
            }
            """.utf8)

            guard let tempItem = try? JSONDecoder().decode(LabelTemplateItem.self, from: templabelJSON) else {
                XCTFail("Not a valid LabelTemplateItem")
                return
            }
            testAccount?.displayHints.labelTemplate.labelTemplateItems.append(tempItem)
        }

        XCTAssertEqual(
            account1.maskedValue(forField: "attributeKey1"), "123451",
            "Mask was: \(account1.maskedValue(forField: "attributeKey1")) should have been: mask1"
        )
        XCTAssertTrue(
            account1.maskedValue(forField: "9999").isEmpty,
            "Mask was: \(account1.maskedValue(forField: "attributeKey1")) should have been nil."
        )

        let attrJSON = Data("""
        {
            "key": "1",
            "status": "READ_ONLY"
        }
        """.utf8)

        let attr2JSON = Data("""
        {
            "key": "2",
            "value": "12345",
            "status": "MUST_WRITE",
            "mustWriteReason": "Must!"
        }
        """.utf8)

        guard let attr = try? JSONDecoder().decode(AccountOnFileAttribute.self, from: attrJSON),
              let attr2 = try? JSONDecoder().decode(AccountOnFileAttribute.self, from: attr2JSON) else {
            XCTFail("Not all attributes are a valid AccountOnFileAttribute object")
            return
        }

        XCTAssertTrue(!account1.hasValue(forField: "999"), "Should not have value.")

        account1.attributes.attributes.append(attr)
        account1.attributes.attributes.append(attr2)

        XCTAssertTrue(account1.hasValue(forField: attr.key), "Should have value.")

        let foundValue = account1.attributes.value(forField: "2")
        XCTAssertEqual(foundValue, attr2.value, "Values are not equal.")

        XCTAssertTrue(account1.attributes.value(forField: "999").isEmpty, "Value should have been empty.")
    }
}
