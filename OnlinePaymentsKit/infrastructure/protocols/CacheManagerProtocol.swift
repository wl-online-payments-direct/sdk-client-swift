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

public protocol CacheManagerProtocol {

    func createCacheKey(prefix: String, suffix: String?, context: PaymentContext) -> String

    func has(key: String) -> Bool

    func get<T>(key: String) -> T?

    func set<T>(key: String, value: T)

    func remove(key: String)

    func clearAll()
}
