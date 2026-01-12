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
import XCTest

@testable import OnlinePaymentsKit

enum FixtureLoader {
    static func loadJSON<T: Decodable>(
        _ name: String,
        as type: T.Type,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> T {
        // Bundle for the test target
        let bundle = Bundle(for: AnyTestBundleMarker.self)

        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            XCTFail("Missing fixture \(name).json in test bundle", file: file, line: line)
            throw NSError(domain: "Tests", code: 1)
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

/// Empty marker class that lives in the test bundle
/// Used by FixtureLoader and Stubs to locate the test bundle
final class AnyTestBundleMarker: NSObject {}
