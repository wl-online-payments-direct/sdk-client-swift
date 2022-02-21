//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class LabelTemplateTestCase: XCTestCase {

    let template = LabelTemplate()

    override func setUp() {
        super.setUp()

        let item1 = LabelTemplateItem(json: ["attributeKey": "key1", "mask": "mask1"])
        let item2 = LabelTemplateItem(json: ["attributeKey": "key2", "mask": "mask2"])

        template.labelTemplateItems.append(item1!)
        template.labelTemplateItems.append(item2!)
    }

    func testMaskForAttributeKey() {
        let mask = template.mask(forAttributeKey: "key1")

        XCTAssertNotNil(mask, "Mask could not be found")
        XCTAssertEqual(mask, "mask1", "Unexpected mask encountered")
    }

}
