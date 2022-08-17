//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class PaymentRequestTestCase: XCTestCase {

    let request = PaymentRequest(paymentProduct: PaymentProduct(json: [
        "fields": [[:]],
        "id": 1,
        "paymentMethod": "card",
        "displayHints": [
            "displayOrder": 20,
            "label": "Visa",
            "logo": "/this/is_a_test.png"
        ]
    ])!)
    let account = AccountOnFile(json: ["id": 1, "paymentProductId": 1])!
    let fieldId = "1"
    var attribute: AccountOnFileAttribute!
    var session = Session(clientSessionId: "client-session-id",
                          customerId: "customer-id",
                          baseURL: "example.com",
                          assetBaseURL: "exampe.com",
                          appIdentifier: "")

    override func setUp() {
        super.setUp()

        attribute = AccountOnFileAttribute(json: ["key": fieldId, "value": "paymentProductFieldValue1", "status": "CAN_WRITE"])!

        account.attributes = AccountOnFileAttributes()
        account.attributes.attributes.append(attribute)
        request.accountOnFile = account

        request.paymentProduct = PaymentProduct(json: [
            "fields": [[:]],
            "id": 1,
            "paymentMethod": "card",
            "displayHints": [
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            ]
        ])!

        let field = PaymentProductField(json: [
            "displayHints": [
                "displayOrder": 0,
                "formElement": [
                    "type": "text"
                ]
            ],
            "id": fieldId,
            "type": "numericstring"
        ])!
        request.paymentProduct?.fields.paymentProductFields.append(field)
        request.paymentProduct?.paymentProductField(withId: fieldId)?.displayHints.mask = "{{9999}} {{9999}} {{9999}} {{9999}} {{9999}}"
        request.setValue(forField: field.identifier, value: "payment1Value")
        request.formatter = StringFormatter()

        request.validate()
    }

    func testGetValue() {
        let value = request.getValue(forField: attribute.key)
        XCTAssertTrue(value != nil, "Did not find value of existing attribute.")

        XCTAssertTrue(request.getValue(forField: "9999") == nil, "Should have been nil: \(request.getValue(forField: "9999")!).")

        XCTAssertTrue(request.getValue(forField: fieldId) == "payment1Value", "Value not found.")
    }

    func testMaskedValue() {
        let value = request.maskedValue(forField: attribute.key)
        XCTAssertTrue(value != nil, "Value was not yet.")

        //TODO: Test masked value
        request.paymentProduct?.paymentProductField(withId: fieldId)?.displayHints.mask = "[[9999]] [[9999]] [[9999]] [[9999]] [[999]]"
        XCTAssertTrue(value != request.maskedValue(forField: fieldId), "Value was not succesfully masked.")

        XCTAssertTrue(request.maskedValue(forField: "999") == nil, "Value was found: \(request.maskedValue(forField: "999")!).")

    }

    func testIsPartOfAccount() {
        guard let field = request.fieldValues.first?.key else {
            XCTFail("There was no field.")
            return
        }

        let isPartOf = request.isPartOfAccountOnFile(field: field)
        XCTAssertTrue(isPartOf, "Was not part of file.")

        XCTAssertTrue(!request.isPartOfAccountOnFile(field: "NotPartOf"), "There is not suppose to be a file.")
    }

    func testIsReadOnly() {
        guard let field = request.fieldValues.first?.key else {
            XCTFail("There was no field.")
            return
        }

        XCTAssertTrue(!request.isReadOnly(field: field), "It is NOT suppose to be read only.")

        account.attributes.attributes.first?.status = .readOnly
        XCTAssertTrue(request.isReadOnly(field: field), "It is suppose to be read only.")

        XCTAssertTrue(!request.isReadOnly(field: "9999"), "It is NOT suppose to be read only.")
    }

    func testUnmaskedValues() {
        print("Masked: \(String(describing: request.maskedValue(forField: fieldId)))")
        XCTAssertTrue(request.unmaskedFieldValues?.first != nil, "No unmasked items.")
        XCTAssertTrue(request.unmaskedFieldValues?.first!.value == "1", "No unmasked items.")
    }

    func testUnmaskedValue() {
        print("Masked: \(String(describing: request.maskedValue(forField: fieldId)))")
        XCTAssertTrue(request.unmaskedValue(forField: fieldId) == "1", "No unmasked items.")

        request.paymentProduct?.paymentProductField(withId: fieldId)?.displayHints.mask = "12345"
        print("Masked: \(String(describing: request.maskedValue(forField: fieldId)))")
        XCTAssertTrue(request.unmaskedValue(forField: fieldId) == "", "No unmasked items.")

        XCTAssertTrue(request.unmaskedValue(forField: "9999") == nil, "Unexpected success.")
    }
}
