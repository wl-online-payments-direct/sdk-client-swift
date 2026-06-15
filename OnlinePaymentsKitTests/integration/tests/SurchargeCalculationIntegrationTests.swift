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

/// DISABLED: All tests in this suite require a surcharge-enabled merchant environment.
class SurchargeCalculationIntegrationTests: BaseIntegrationTest {

    // MARK: - Test Constants (fill in when enabling these tests)

    /// Partial card number (first 6-8 digits) of a card that has surcharge applied
    private let surchargeCardNumber = ""
    /// Payment product ID corresponding to the surcharge card
    private let surchargeProductId = 0
    /// Token for a previously tokenized surcharge card
    private let surchargeToken = ""
    /// Partial card number (first 6-8 digits) of a card without surcharge
    private let noSurchargeCardNumber = ""
    /// Payment product ID corresponding to the no-surcharge card
    private let noSurchargeProductId = 0

    private var amountOfMoney: AmountOfMoney {
        AmountOfMoney(amount: 1000, currencyCode: "EUR")
    }

    func testGetSurchargeCalculation_WithCardAndProductId_ReturnsSurchargeResponse() throws {
        try XCTSkipIf(true, "DISABLED: Requires surcharge-enabled merchant environment")

        let expectation = expectation(description: "Get surcharge calculation with card and product ID")

        sdk.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            partialCardNumber: surchargeCardNumber,
            paymentProductId: NSNumber(value: surchargeProductId),
            success: { response in
                XCTAssertFalse(response.surcharges.isEmpty, "Should have at least one surcharge entry")
                
                let surcharge = response.surcharges[0]
                
                XCTAssertEqual(SurchargeResult.ok, surcharge.result)
                XCTAssertGreaterThan(surcharge.surchargeAmount.amount, 0, "Surcharge amount should be greater than 0")
                XCTAssertEqual(
                    surcharge.netAmount.amount + surcharge.surchargeAmount.amount,
                    surcharge.totalAmount.amount,
                    "Total should equal net + surcharge"
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

    func testGetSurchargeCalculation_WithCardAndNoProductId_ReturnsSurchargeResponse() throws {
        try XCTSkipIf(true, "DISABLED: Requires surcharge-enabled merchant environment")

        let expectation = expectation(description: "Get surcharge calculation with card and no product ID")

        sdk.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            partialCardNumber: surchargeCardNumber,
            success: { response in
                XCTAssertFalse(response.surcharges.isEmpty, "Should have at least one surcharge entry")
                
                let surcharge = response.surcharges[0]
                
                XCTAssertEqual(SurchargeResult.ok, surcharge.result)
                XCTAssertGreaterThan(surcharge.surchargeAmount.amount, 0, "Surcharge amount should be greater than 0")
                XCTAssertEqual(
                    surcharge.netAmount.amount + surcharge.surchargeAmount.amount,
                    surcharge.totalAmount.amount,
                    "Total should equal net + surcharge"
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

    func testGetSurchargeCalculation_WithToken_ReturnsSurchargeResponse() throws {
        try XCTSkipIf(true, "DISABLED: Requires surcharge-enabled merchant environment")

        let expectation = expectation(description: "Get surcharge calculation with token")

        sdk.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            token: surchargeToken,
            success: { response in
                XCTAssertFalse(response.surcharges.isEmpty, "Should have at least one surcharge entry")
                
                let surcharge = response.surcharges[0]
                
                XCTAssertEqual(SurchargeResult.ok, surcharge.result)
                XCTAssertGreaterThan(surcharge.surchargeAmount.amount, 0, "Surcharge amount should be greater than 0")
                XCTAssertEqual(
                    surcharge.netAmount.amount + surcharge.surchargeAmount.amount,
                    surcharge.totalAmount.amount,
                    "Total should equal net + surcharge"
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

    func testGetSurchargeCalculation_WithNoSurchargeCardAndProductId_ReturnsNoSurchargeResponse() throws {
        try XCTSkipIf(true, "DISABLED: Requires surcharge-enabled merchant environment")

        let expectation = expectation(description: "Get surcharge calculation with no-surcharge card and product ID")

        sdk.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            partialCardNumber: noSurchargeCardNumber,
            paymentProductId: NSNumber(value: noSurchargeProductId),
            success: { response in
                XCTAssertFalse(response.surcharges.isEmpty, "Should have at least one surcharge entry")
                
                let surcharge = response.surcharges[0]
                
                XCTAssertEqual(SurchargeResult.noSurcharge, surcharge.result)
                XCTAssertEqual(0, surcharge.surchargeAmount.amount, "Surcharge amount should be 0")
                XCTAssertEqual(
                    surcharge.netAmount.amount,
                    surcharge.totalAmount.amount,
                    "Total should equal net amount when no surcharge"
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

    func testGetSurchargeCalculation_WithNoSurchargeCardAndNoProductId_ReturnsNoSurchargeResponse() throws {
        try XCTSkipIf(true, "DISABLED: Requires surcharge-enabled merchant environment")

        let expectation = expectation(description: "Get surcharge calculation with no-surcharge card and no product ID")

        sdk.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            partialCardNumber: noSurchargeCardNumber,
            success: { response in
                XCTAssertFalse(response.surcharges.isEmpty, "Should have at least one surcharge entry")
                
                let surcharge = response.surcharges[0]
                
                XCTAssertEqual(SurchargeResult.noSurcharge, surcharge.result)
                XCTAssertEqual(0, surcharge.surchargeAmount.amount, "Surcharge amount should be 0")
                XCTAssertEqual(
                    surcharge.netAmount.amount,
                    surcharge.totalAmount.amount,
                    "Total should equal net amount when no surcharge"
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

    func testGetSurchargeCalculation_WhenCalledAgain_ReturnsCachedResult() throws {
        try XCTSkipIf(true, "DISABLED: Requires surcharge-enabled merchant environment")

        let firstExpectation = expectation(description: "First call")
        let secondExpectation = expectation(description: "Second call")

        var firstCallTime: TimeInterval = 0
        var secondCallTime: TimeInterval = 0

        let firstStart = Date()
        sdk.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            token: surchargeToken,
            success: { firstResult in
                firstCallTime = Date().timeIntervalSince(firstStart)
                XCTAssertNotNil(firstResult)
                firstExpectation.fulfill()

                let secondStart = Date()
                self.sdk.surchargeCalculation(
                    amountOfMoney: self.amountOfMoney,
                    token: self.surchargeToken,
                    success: { secondResult in
                        secondCallTime = Date().timeIntervalSince(secondStart)
                        
                        XCTAssertNotNil(secondResult)
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
