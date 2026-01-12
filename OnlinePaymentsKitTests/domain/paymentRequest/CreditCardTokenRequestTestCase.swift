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

class CreditCardTokenRequestTests: XCTestCase {

    var tokenRequest: CreditCardTokenRequest!

    override func setUp() {
        super.setUp()
        tokenRequest = CreditCardTokenRequest()
    }

    override func tearDown() {
        tokenRequest = nil
        super.tearDown()
    }

    func testGetValuesWhenNoValuesAreSetReturnsEmptyDictionary() {
        XCTAssertEqual(tokenRequest.getValues().count, 0)
    }

    func testGetValuesWhenAllValuesAreSetReturnsAllValues() {
        tokenRequest.cardNumber = "4567350000427977"
        tokenRequest.cardholderName = "John Doe"
        tokenRequest.expiryDate = "12/2030"
        tokenRequest.securityCode = "123"

        let values = tokenRequest.getValues()

        XCTAssertEqual(values["cardNumber"], "4567350000427977")
        XCTAssertEqual(values["cardholderName"], "John Doe")
        XCTAssertEqual(values["expiryDate"], "12/2030")
        XCTAssertEqual(values["cvv"], "123")
    }

    func testCardNumberCanBeSetAndRetrieved() {
        tokenRequest.cardNumber = "4567350000427977"
        XCTAssertEqual(tokenRequest.cardNumber, "4567350000427977")
    }

    func testCardHolderNameCanBeSetAndRetrieved() {
        tokenRequest.cardholderName = "Test cardholder name"
        XCTAssertEqual(tokenRequest.cardholderName, "Test cardholder name")
    }

    func testExpiryDateCanBeSetAndRetrieved() {
        tokenRequest.expiryDate = "12/2030"
        XCTAssertEqual(tokenRequest.expiryDate, "12/2030")
    }

    func testPaymentProductIdCanBeSetAndRetrieved() {
        tokenRequest.paymentProductId = NSNumber(value: 1)
        XCTAssertEqual(tokenRequest.paymentProductId, NSNumber(value: 1))
    }

    func testSecurityCodeCanBeSetAndRetrieved() {
        tokenRequest.securityCode = "123"
        XCTAssertEqual(tokenRequest.securityCode, "123")
    }
}
