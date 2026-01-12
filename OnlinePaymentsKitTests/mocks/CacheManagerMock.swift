/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation

@testable import OnlinePaymentsKit

class CacheManagerMock: CacheManagerProtocol {

    var createCacheKeyCallCount = 0
    var hasCallCount = 0
    var getCallCount = 0
    var setCallCount = 0
    var removeCallCount = 0
    var clearAllCallCount = 0

    var getCalledWithKey: String?
    var setCalledWithKey: String?
    var setCalledWithValue: Any?

    internal var cache: [String: Any] = [:]

    func createCacheKey(prefix: String, suffix: String?, context: PaymentContext) -> String {
        createCacheKeyCallCount += 1

        let components = [
            prefix,
            "\(context.amountOfMoney.amount)",
            context.countryCode,
            context.amountOfMoney.currencyCode,
            "\(context.isRecurring)",
            suffix,
        ].compactMap { $0 }

        return components.joined(separator: "-")
    }

    func has(key: String) -> Bool {
        hasCallCount += 1
        return cache[key] != nil
    }

    func get<T>(key: String) -> T? {
        getCallCount += 1
        getCalledWithKey = key
        return cache[key] as? T
    }

    func set<T>(key: String, value: T) {
        setCallCount += 1
        setCalledWithKey = key
        setCalledWithValue = value
        cache[key] = value
    }

    func remove(key: String) {
        removeCallCount += 1
        cache.removeValue(forKey: key)
    }

    func clearAll() {
        clearAllCallCount += 1
        cache.removeAll()
    }
}
