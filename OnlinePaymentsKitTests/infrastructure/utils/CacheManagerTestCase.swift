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

class CacheManagerTestCase: XCTestCase {

    var cacheManager: CacheManager!
    var context: PaymentContext!

    override func setUp() {
        super.setUp()
        cacheManager = CacheManager()

        context = PaymentContext(
            amountOfMoney: AmountOfMoney(amount: 1000, currencyCode: "USD"),
            isRecurring: false,
            countryCode: "US"
        )
    }

    func testCreateCacheKeyWithAllComponents() {
        let key = cacheManager.createCacheKey(
            prefix: "products",
            suffix: "test",
            context: context
        )

        XCTAssertEqual(key, "products-1000_US_false_USD_test")
    }

    func testCreateCacheKeyWithoutSuffix() {
        let key = cacheManager.createCacheKey(
            prefix: "products",
            context: context
        )

        XCTAssertEqual(key, "products-1000_US_false_USD")
    }

    func testSetAndGet() {
        let key = "test_key"
        let value = "test_value"

        cacheManager.set(key: key, value: value)

        let retrieved: String? = cacheManager.get(key: key)
        XCTAssertEqual(retrieved, value)
    }

    func testHasReturnsTrueForExistingKey() {
        let key = "test_key"
        cacheManager.set(key: key, value: "value")

        XCTAssertTrue(cacheManager.has(key: key))
    }

    func testHasReturnsFalseForNonExistingKey() {
        XCTAssertFalse(cacheManager.has(key: "non_existing"))
    }

    func testGetReturnsNilForNonExistingKey() {
        let value: String? = cacheManager.get(key: "non_existing")
        XCTAssertNil(value)
    }

    func testRemove() {
        let key = "test_key"
        cacheManager.set(key: key, value: "value")

        cacheManager.remove(key: key)

        XCTAssertFalse(cacheManager.has(key: key))
    }

    func testClearAll() {
        cacheManager.set(key: "key1", value: "value1")
        cacheManager.set(key: "key2", value: "value2")

        cacheManager.clearAll()

        XCTAssertFalse(cacheManager.has(key: "key1"))
        XCTAssertFalse(cacheManager.has(key: "key2"))
    }

    func testConcurrentAccess() {
        let expectation = self.expectation(description: "Concurrent operations complete")
        let iterations = 1000
        var completedOperations = 0
        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)

        // Perform concurrent writes
        for i in 0..<iterations {
            queue.async {
                self.cacheManager.set(key: "key\(i)", value: "value\(i)")

                if i == iterations - 1 {
                    DispatchQueue.main.async {
                        completedOperations += 1
                        if completedOperations == 2 {
                            expectation.fulfill()
                        }
                    }
                }
            }
        }

        // Perform concurrent reads
        for i in 0..<iterations {
            queue.async {
                let _: String? = self.cacheManager.get(key: "key\(i)")

                if i == iterations - 1 {
                    DispatchQueue.main.async {
                        completedOperations += 1
                        if completedOperations == 2 {
                            expectation.fulfill()
                        }
                    }
                }
            }
        }

        waitForExpectations(timeout: 5.0)

        // Verify all values were set correctly
        for i in 0..<iterations {
            let value: String? = cacheManager.get(key: "key\(i)")
            XCTAssertEqual(value, "value\(i)", "Value for key\(i) should be value\(i)")
        }
    }

    func testTypeMismatchReturnsNil() {
        let key = "test_key"

        // Store a String value
        cacheManager.set(key: key, value: "test_string")

        // Try to retrieve as String - should work
        let stringValue: String? = cacheManager.get(key: key)
        XCTAssertEqual(stringValue, "test_string")

        // Try to retrieve as Int - should return nil due to type mismatch
        let intValue: Int? = cacheManager.get(key: key)
        XCTAssertNil(intValue, "Type mismatch should return nil")

        // Original value should still be retrievable as correct type
        let stringValueAgain: String? = cacheManager.get(key: key)
        XCTAssertEqual(stringValueAgain, "test_string")
    }
}
