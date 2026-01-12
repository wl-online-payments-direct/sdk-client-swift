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

/// Thread-safe cache manager using a concurrent dispatch queue with barrier writes.
///
/// This implementation uses the reader-writer pattern where:
/// - Multiple reads can happen concurrently
/// - Writes are exclusive and block other operations
public class CacheManager: CacheManagerProtocol {
    private var cache: [String: Any] = [:]
    private let queue = DispatchQueue(
        label: "com.worldline.onlinepayments.cacheManager",
        attributes: .concurrent
    )

    public init() {}

    /**
     Creates a unique cache key based on the given context and optional parameters.

     - Parameters:
        - prefix: The prefix to prepend to the cache key.
        - suffix: Optional suffix to append to the cache key.
        - context: The payment context providing data for the cache key generation.

     - Returns: The generated cache key.
     */
    public func createCacheKey(
        prefix: String,
        suffix: String? = nil,
        context: PaymentContext
    ) -> String {
        let amount = "\(context.amountOfMoney.amount)"
        let countryCode = context.countryCode
        let isRecurring = "\(context.isRecurring)"
        let currencyCode = context.amountOfMoney.currencyCode

        let components = [
            amount,
            countryCode,
            isRecurring,
            currencyCode,
            suffix,
        ].compactMap { $0 }

        let key = components.joined(separator: "_")
        return "\(prefix)-\(key)"
    }

    public func has(key: String) -> Bool {
        return queue.sync {
            cache[key] != nil
        }
    }

    public func get<T>(key: String) -> T? {
        return queue.sync {
            guard let value = cache[key] else {
                return nil
            }

            guard let typedValue = value as? T else {
                #if DEBUG
                print("⚠️ CacheManager: Type mismatch for key '\(key)': expected \(T.self), got \(type(of: value))")
                #endif
                return nil
            }

            return typedValue
        }
    }

    public func set<T>(key: String, value: T) {
        queue.sync(flags: .barrier) {
            cache[key] = value
        }
    }

    public func remove(key: String) {
        queue.sync(flags: .barrier) {
            _ = cache.removeValue(forKey: key)
        }
    }

    public func clearAll() {
        queue.sync(flags: .barrier) {
            cache.removeAll()
        }
    }
}
