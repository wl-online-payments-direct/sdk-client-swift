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

/// Integration tests for getCurrencyConversionQuote.
/// All tests are DISABLED — requires a merchant environment configured for DCC.
/// To enable: remove XCTSkipIf(true, ...) and fill in the private constants below.
class CurrencyConversionIntegrationTests: BaseIntegrationTest {

    // MARK: - Constants (fill in to enable tests)
    private let dccCardNumber = ""          // partial card number that supports DCC
    private let dccProductId: Int = 0       // product ID for DCC-supporting card
    private let dccToken = ""               // token for DCC-supporting card
    private let noDccCardNumber = ""        // partial card number with no DCC support
    private let noDccProductId: Int = 0     // product ID for non-DCC card
    private let noDccToken = ""             // token for non-DCC card

    private var amountOfMoney: AmountOfMoney {
        AmountOfMoney(amount: 1000, currencyCode: "AUD")
    }

    // MARK: - Tests

    func testGetCurrencyConversionQuote_WithCardAndProductId_ReturnsBaseAmount() throws {
        try XCTSkipIf(true, "DISABLED: Requires merchant environment configured for DCC")

        let expectation = expectation(description: "DCC quote with card and product ID")

        sdk.currencyConversionQuote(
            amountOfMoney: amountOfMoney,
            partialCardNumber: dccCardNumber,
            paymentProductId: NSNumber(value: dccProductId),
            success: { response in
                XCTAssertEqual(
                    self.amountOfMoney.amount,
                    response.proposal.baseAmount.amount,
                    "Base amount should match input amount"
                )
                XCTAssertEqual(
                    self.amountOfMoney.currencyCode,
                    response.proposal.baseAmount.currencyCode,
                    "Base currency should match input currency"
                )
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetCurrencyConversionQuote_WithCardAndNoProductId_ReturnsBaseAmount() throws {
        try XCTSkipIf(true, "DISABLED: Requires merchant environment configured for DCC")

        let expectation = expectation(description: "DCC quote with card and no product ID")

        sdk.currencyConversionQuote(
            amountOfMoney: amountOfMoney,
            partialCardNumber: dccCardNumber,
            paymentProductId: nil,
            success: { response in
                XCTAssertEqual(
                    self.amountOfMoney.amount,
                    response.proposal.baseAmount.amount,
                    "Base amount should match input amount"
                )
                XCTAssertEqual(
                    self.amountOfMoney.currencyCode,
                    response.proposal.baseAmount.currencyCode,
                    "Base currency should match input currency"
                )
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetCurrencyConversionQuote_WithToken_ReturnsBaseAmount() throws {
        try XCTSkipIf(true, "DISABLED: Requires merchant environment configured for DCC")

        let expectation = expectation(description: "DCC quote with token")

        sdk.currencyConversionQuote(
            amountOfMoney: amountOfMoney,
            token: dccToken,
            success: { response in
                XCTAssertEqual(
                    self.amountOfMoney.amount,
                    response.proposal.baseAmount.amount,
                    "Base amount should match input amount"
                )
                XCTAssertEqual(
                    self.amountOfMoney.currencyCode,
                    response.proposal.baseAmount.currencyCode,
                    "Base currency should match input currency"
                )
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetCurrencyConversionQuote_WithNoConversionCardAndProductId_ThrowsResponseError() throws {
        try XCTSkipIf(true, "DISABLED: Requires merchant environment configured for DCC")

        let expectation = expectation(description: "DCC quote error with card and product ID")

        sdk.currencyConversionQuote(
            amountOfMoney: amountOfMoney,
            partialCardNumber: noDccCardNumber,
            paymentProductId: NSNumber(value: noDccProductId),
            success: { _ in
                XCTFail("Should throw error for card without DCC support")
                expectation.fulfill()
            },
            failure: { error in
                XCTAssertTrue(error is ResponseError, "Error should be a ResponseError")
                if let responseError = error as? ResponseError {
                    XCTAssertEqual(
                        404,
                        responseError.httpStatusCode,
                        "HTTP status code should be 404 for no DCC card"
                    )
                }

                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetCurrencyConversionQuote_WithNoConversionCardAndNoProductId_ThrowsResponseError() throws {
        try XCTSkipIf(true, "DISABLED: Requires merchant environment configured for DCC")

        let expectation = expectation(description: "DCC quote error with card and no product ID")

        sdk.currencyConversionQuote(
            amountOfMoney: amountOfMoney,
            partialCardNumber: noDccCardNumber,
            paymentProductId: nil,
            success: { _ in
                XCTFail("Should throw error for card without DCC support")
                expectation.fulfill()
            },
            failure: { error in
                XCTAssertTrue(error is ResponseError, "Error should be a ResponseError")
                if let responseError = error as? ResponseError {
                    XCTAssertEqual(
                        404,
                        responseError.httpStatusCode,
                        "HTTP status code should be 404 for no DCC card"
                    )
                }

                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }
    
    func testGetCurrencyConversionQuote_WithNoConversionToken_ThrowsResponseError() throws {
        try XCTSkipIf(true, "DISABLED: Requires merchant environment configured for DCC")

        let expectation = expectation(description: "DCC quote error with token")

        sdk.currencyConversionQuote(
            amountOfMoney: amountOfMoney,
            token: noDccToken,
            success: { _ in
                XCTFail("Should throw error for token without DCC support")
                expectation.fulfill()
            },
            failure: { error in
                XCTAssertTrue(error is ResponseError, "Error should be a ResponseError")

                if let responseError = error as? ResponseError {
                    XCTAssertEqual(
                        404,
                        responseError.httpStatusCode,
                        "HTTP status code should be 404 for token without DCC support"
                    )
                }

                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetCurrencyConversionQuote_WhenCalledAgain_ReturnsCachedResult() throws {
        try XCTSkipIf(true, "DISABLED: Requires merchant environment configured for DCC")

        let firstExpectation = expectation(description: "First call")
        let secondExpectation = expectation(description: "Second call")

        var firstCallTime: TimeInterval = 0
        var secondCallTime: TimeInterval = 0

        let firstStart = Date()
        sdk.currencyConversionQuote(
            amountOfMoney: amountOfMoney,
            token: dccToken,
            success: { firstResult in
                firstCallTime = Date().timeIntervalSince(firstStart)
                firstExpectation.fulfill()

                let secondStart = Date()
                self.sdk.currencyConversionQuote(
                    amountOfMoney: self.amountOfMoney,
                    token: self.dccToken,
                    success: { secondResult in
                        secondCallTime = Date().timeIntervalSince(secondStart)
                        XCTAssertTrue(
                            secondCallTime < 0.1,
                            "Cached call should complete in under 100ms: \(secondCallTime)s"
                        )
                        XCTAssertTrue(
                            secondCallTime < firstCallTime,
                            "Second call should be faster (cached)"
                        )
                        secondExpectation.fulfill()
                    },
                    failure: { error in
                        XCTFail("Second call should not fail: \(error)")
                        secondExpectation.fulfill()
                    }
                )
            },
            failure: { error in
                XCTFail("First call should not fail: \(error)")
                firstExpectation.fulfill()
                secondExpectation.fulfill()
            }
        )

        waitForExpectations(timeout: 15.0)
    }
}
