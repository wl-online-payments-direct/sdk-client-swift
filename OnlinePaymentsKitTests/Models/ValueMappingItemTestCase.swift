//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class ValueMappingItemTestCase: XCTestCase {

    func testValueMapping() {
        let item = ValueMappingItem(json: ["displayName": "displayName", "value": "value"])!

        XCTAssertTrue(item.displayName == "displayName", "Unexpected")
        XCTAssertTrue(item.value == "value", "Unexpected")
    }
}
