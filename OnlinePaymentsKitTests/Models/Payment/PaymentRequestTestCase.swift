//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest

@testable import OnlinePaymentsKit

class PaymentRequestTestCase: XCTestCase {
    var request: PaymentRequest!
    var account: AccountOnFile!
    let creditCardFieldName = "creditCard"
    let expiryDateFieldName = "expiryDate"
    let maskedValidCardNumber = "4242 4242 4242 4242"
    let unmaskedValidCardNumber = "4242424242424242"
    let maskedValidExpiryDate = "12/35"
    let unmaskedValidExpiryDate = "1235"
    var attribute: AccountOnFileAttribute!
    var session = Session(
        clientSessionId: "client-session-id",
        customerId: "customer-id",
        baseURL: "https://example.com",
        assetBaseURL: "https://example.com",
        appIdentifier: ""
    )

    override func setUp() {
        super.setUp()

        let paymentProductJSON = Data(
            """
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
            """.utf8
        )

        guard let paymentProduct = try? JSONDecoder().decode(PaymentProduct.self, from: paymentProductJSON)
        else {
            XCTFail("Not a valid PaymentProduct")

            return
        }

        request = PaymentRequest(paymentProduct: paymentProduct)
        let accountJSON = Data(
            """
            {
                "id": "1",
                "paymentProductId": 1,
                "attributes": [
                    {
                        "key": "\(creditCardFieldName)",
                        "value": "can_write_field_value",
                        "status": "CAN_WRITE"
                    },
                    {
                        "key": "read_only_field",
                        "value": "read_only_field_value",
                        "status": "READ_ONLY"
                    },
                    {
                        "key": "must_write_field",
                        "value": "must_write_field_value",
                        "status": "MUST_WRITE"
                    }
                ]
            }
            """.utf8
        )
        account = try? JSONDecoder().decode(AccountOnFile.self, from: accountJSON)
        guard let account
        else {
            XCTFail("Not a valid AccountOnFile")

            return
        }

        attribute = account.attributes.attributes.first
        request.accountOnFile = account
        let fieldDictionary =
            [
                "displayHints": [
                    "displayOrder": 0,
                    "mask": "{{9999}} {{9999}} {{9999}} {{9999}} {{999}}",
                    "formElement": [
                        "type": "text"
                    ],
                ],
                "id": creditCardFieldName,
                "type": "numericstring",
                "dataRestrictions": [
                    "isRequired": true,
                    "validators": [
                        "luhn": [],
                        "length": [
                            "minLength": 13,
                            "maxLength": 19,
                        ],
                        "regularExpression": [
                            "regularExpression": "^[0-9]*$"
                        ],
                    ],
                ],
            ] as [String: Any]

        let expityDateDictionary =
            [
                "displayHints": [
                    "displayOrder": 1,
                    "mask": "{{99}}/{{99}}",
                    "formElement": [
                        "type": "text"
                    ],
                ],
                "id": expiryDateFieldName,
                "type": "expirydate",
                "dataRestrictions": [
                    "isRequired": true,
                    "validators": [
                        "expirationDate": [],
                        "regularExpression":[
                           "regularExpression":"^(0[1-9]|1[0-2])(\\d{2})$"
                        ],
                        "length": [
                            "minLength": 4,
                            "maxLength": 6,
                        ],
                    ],
                ],
            ] as [String: Any]

        for fieldDict in [fieldDictionary, expityDateDictionary] {
            guard let fieldJSON = try? JSONSerialization.data(withJSONObject: fieldDict, options: [])
            else {
                XCTFail("Not a valid Dictionary")

                return
            }

            guard let field = try? JSONDecoder().decode(PaymentProductField.self, from: fieldJSON)
            else {
                XCTFail("Not a valid PaymentProductField")

                return
            }

            request.paymentProduct?.fields.paymentProductFields.append(field)
        }

        request.setValue(forField: creditCardFieldName, value: maskedValidCardNumber)
        request.setValue(forField: expiryDateFieldName, value: maskedValidExpiryDate)
        request.formatter = StringFormatter()
    }

    func testGetValue() {
        let value = request.getValue(forField: attribute.key)
        XCTAssertTrue(value != nil, "Did not find value of existing attribute.")

        XCTAssertTrue(
            request.getValue(forField: "9999") == nil,
            "Should have been nil: \(request.getValue(forField: "9999")!)."
        )

        XCTAssertTrue(request.getValue(forField: creditCardFieldName) == maskedValidCardNumber, "Value not found.")
        XCTAssertTrue(request.getValue(forField: expiryDateFieldName) == maskedValidExpiryDate, "Value not found.")
    }

    func testMaskedValue() {
        let value = request.maskedValue(forField: attribute.key)
        XCTAssertTrue(value != nil, "Value was not yet.")

        request.paymentProduct?.paymentProductField(withId: creditCardFieldName)?.displayHints.mask =
            "[[9999]] [[9999]] [[9999]] [[9999]] [[999]]"
        XCTAssertTrue(value != request.maskedValue(forField: creditCardFieldName), "Value was not succesfully masked.")

        XCTAssertTrue(
            request.maskedValue(forField: "999") == nil,
            "Value was found: \(request.maskedValue(forField: "999")!)."
        )
    }

    func testRemoveValue() {
        let value = request.getValue(forField: creditCardFieldName)
        XCTAssertNotNil(value)

        request.removeValue(forField: creditCardFieldName)

        let removedValue = request.getValue(forField: creditCardFieldName)
        XCTAssertNil(removedValue)
    }

    func testIsPartOfAccount() {
        XCTAssertTrue(
            request.isPartOfAccountOnFile(field: creditCardFieldName),
            "Field '\(creditCardFieldName) should be part of the account"
        )

        XCTAssertFalse(
            request.isPartOfAccountOnFile(field: "NotPartOf"),
            "Field 'NotPartOf' should not be part of the account"
        )

    }

    func testIsReadOnly() {
        guard let field = request.fieldValues.first?.key
        else {
            XCTFail("There was no field.")

            return
        }

        XCTAssertTrue(!request.isReadOnly(field: creditCardFieldName), "It is NOT suppose to be read only.")
        XCTAssertTrue(!request.isReadOnly(field: expiryDateFieldName), "It is NOT suppose to be read only.")
        if let index = account.attributes.attributes.firstIndex(where: { $0.key == field }) {
            account.attributes.attributes[index].status = .readOnly
        }
    }

    func testUnmaskedValues() {
        XCTAssertTrue(request.unmaskedFieldValues?.first != nil, "No unmasked items.")

        let cardUnmasked = request.unmaskedValue(forField: creditCardFieldName)
        XCTAssertEqual(cardUnmasked, unmaskedValidCardNumber, "No unmasked items.")

        let expiryUnmasked = request.unmaskedValue(forField: expiryDateFieldName)
        XCTAssertEqual(expiryUnmasked, unmaskedValidExpiryDate, "No unmasked items.")
    }

    func testUnmaskedValue() {
        print("Masked: \(String(describing: request.maskedValue(forField: creditCardFieldName)))")
        XCTAssertTrue(
            request.unmaskedValue(forField: creditCardFieldName) == unmaskedValidCardNumber,
            "No unmasked items."
        )

        request.paymentProduct?.paymentProductField(withId: creditCardFieldName)?.displayHints.mask = "12345"
        print("Masked: \(String(describing: request.maskedValue(forField: creditCardFieldName)))")
        XCTAssertTrue(request.unmaskedValue(forField: creditCardFieldName) == "", "No unmasked items.")

        XCTAssertTrue(request.unmaskedValue(forField: "9999") == nil, "Unexpected success.")
    }

    func testCardNumberValidation() {
        // Remove from AOF beceause otherwise it won't validate
        request.accountOnFile?.attributes.attributes.removeAll { $0.key == creditCardFieldName }

        request.setValue(forField: creditCardFieldName, value: maskedValidCardNumber)
        var errors = request.validate()
        XCTAssertTrue(errors.isEmpty, "Should pass all validation")

        request.setValue(forField: creditCardFieldName, value: unmaskedValidCardNumber)
        errors = request.validate()
        XCTAssertTrue(errors.isEmpty, "Should pass all validation")

        request.setValue(forField: creditCardFieldName, value: "4242a4242b4242c4")
        errors = request.validate()
        XCTAssertFalse(errors.isEmpty, "Should fail due to regex validation (only digits)")

        request.setValue(forField: creditCardFieldName, value: "4242.24#424242'2")
        errors = request.validate()
        XCTAssertFalse(errors.isEmpty, "Should fail due to format validation (special caracters)")

        request.setValue(forField: creditCardFieldName, value: "4242 4242 4242")
        errors = request.validate()
        XCTAssertFalse(errors.isEmpty, "Should fail due to lenght validation (too short)")

        request.setValue(forField: creditCardFieldName, value: "1234 5678 9012 3456 7890")
        errors = request.validate()
        XCTAssertFalse(errors.isEmpty, "Should fail due to lenght validation (too long)")

        request.setValue(forField: creditCardFieldName, value: "1234567890123456")
        errors = request.validate()
        XCTAssertFalse(errors.isEmpty, "Should fail due to invali Luhn check")

        request.setValue(forField: creditCardFieldName, value: "1234 5678 9012 3456")
        errors = request.validate()
        XCTAssertFalse(errors.isEmpty, "Should fail due to invali Luhn check")
    }

    func testExpirationDateValidation() {
        request.setValue(forField: expiryDateFieldName, value: maskedValidExpiryDate)
        var errors = request.validate()
        XCTAssertTrue(errors.isEmpty, "Expiration date validation should pass")

        request.setValue(forField: expiryDateFieldName, value: unmaskedValidExpiryDate)
        errors = request.validate()
        XCTAssertTrue(errors.isEmpty, "Expiration date validation should pass")

        request.setValue(forField: expiryDateFieldName, value: "01/20")
        errors = request.validate()
        XCTAssertFalse(errors.isEmpty, "Expiration date validation should fail for past day")

        request.setValue(forField: expiryDateFieldName, value: "13/25")
        errors = request.validate()
        XCTAssertFalse(errors.isEmpty, "Expiration date validation should fail invalid month")

        request.setValue(forField: expiryDateFieldName, value: "0r/28")
        errors = request.validate()
        XCTAssertFalse(errors.isEmpty, "Expiration date validation should fail for letter in month/year")

        request.setValue(forField: expiryDateFieldName, value: "06/.8")
        errors = request.validate()
        XCTAssertFalse(errors.isEmpty, "Expiration date validation should fail for special caracters in month/year")

        request.setValue(forField: expiryDateFieldName, value: "06/028")
        errors = request.validate()
        XCTAssertFalse(errors.isEmpty, "Expiration date validation should fail for year out of range")

        request.setValue(forField: expiryDateFieldName, value: "6/28")
        errors = request.validate()
        XCTAssertFalse(errors.isEmpty, "Expiration date validation should fail for month out of range")
    }

    func testPrepare() {
        let host = "example.com"
        stub(condition: isHost("\(host)") && isPath("/client/v1/customer-id/crypto/publickey") && isMethodGET()) { _ in
            // swiftlint:disable line_length
            let response = [
                "keyId": "86b64e4e-f43e-4a27-9863-9bbd5b499f82",
                "publicKey":
                    """
                MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkiJlGL1QjUnGDLpMNBtZPYVtOU121jfFcV4WrZayfw9Ib/1AtPBHP/0ZPocdA23zDh6aB+QiOQEkHZlfnelBNnEzEu4ibda3nDdjSrKveSiQPyB5X+u/IS3CR48B/g4QJ+mcMV9hoFt6Hx3R99A0HWMs4um8elQsgB11MsLmGb1SuLo0S1pgL3EcckXfBDNMUBMQ9EtLC9zQW6Y0kx6GFXHgyjNb4yixXfjo194jfhei80sVQ49Y/SHBt/igATGN1l18IBDtO0eWmWeBckwbNkpkPLAvJfsfa3JpaxbXwg3rTvVXLrIRhvMYqTsQmrBIJDl7F6igPD98Y1FydbKe5QIDAQAB
                """,
            ]
            // swiftlint:enable line_length
            return HTTPStubsResponse(
                jsonObject: response,
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }

        let expectation = self.expectation(description: "Response provided")

        session.prepare(
            request,
            success: { (_) in
                expectation.fulfill()
            },
            failure: { (error) in
                XCTFail("Prepare failed: \(error).")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
}
