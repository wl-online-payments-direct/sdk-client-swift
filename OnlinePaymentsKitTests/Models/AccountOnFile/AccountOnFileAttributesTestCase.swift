//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class AccountOnFileAttributesTestCase: XCTestCase {

    let attributes = AccountOnFileAttributes()

    override func setUp() {
        super.setUp()

        let attribute1 = AccountOnFileAttribute(json: ["key": "key1", "value": "value1", "status": "READ_ONLY"])!
        let attribute2 = AccountOnFileAttribute(json: ["key": "key2", "value": "value2", "status": "CAN_WRITE"])!

        attributes.attributes.append(attribute1)
        attributes.attributes.append(attribute2)
    }

    func testValueForField() {
        XCTAssertEqual(attributes.value(forField: "key1"), "value1", "Incorrect value for key")
    }

    func testHasValueForFieldYes() {
        XCTAssert(attributes.hasValue(forField: "key1"), "Attributes should have a value for this key")
    }

    func testHasValueForFieldNo() {
        XCTAssert(!attributes.hasValue(forField: "key3"), "Attributes should not have a value for this key")
    }

    func testIsReadOnly() {
        let readOnlyAttr = AccountOnFileAttribute(json: ["key": "key3", "value": "value3", "status": "READ_ONLY"])!
        attributes.attributes.append(readOnlyAttr)
        XCTAssertTrue(attributes.isReadOnly(field: readOnlyAttr.key), "readOnlyAttr is not read only.")

        let readableAttr = AccountOnFileAttribute(json: ["key": "readable", "value": "value3", "status": "CAN_WRITE"])!
        attributes.attributes.append(readableAttr)
        XCTAssertTrue(!attributes.isReadOnly(field: readableAttr.key), "readableAttr is read only.")

        let mustWriteAttr = AccountOnFileAttribute(json: ["key": "readable", "value": "value3", "status": "MUST_WRITE"])!
        attributes.attributes.append(mustWriteAttr)
        XCTAssertTrue(!attributes.isReadOnly(field: mustWriteAttr.key), "mustWriteAttr is read only.")
    }

}
