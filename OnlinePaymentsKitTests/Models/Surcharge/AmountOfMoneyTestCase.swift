//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 12/09/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import Foundation

import XCTest
@testable import OnlinePaymentsKit

class AmountOfMoneyTestCase: XCTestCase {

    func testAmountOfMoneyDescription() {
        let amount = AmountOfMoney(totalAmount: 3, currencyCode: "EUR")
        XCTAssertEqual(amount.description, "3-EUR")
    }
}
