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
import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest

/// Helper class for stubbing HTTP requests with JSON fixture files
final class Stubs {
    /// Stubs an HTTP request with a JSON fixture file
    /// - Parameters:
    ///   - fixtureName: Name of the JSON file (without .json extension) in supportingFiles
    ///   - condition: OHHTTPStubs condition to match the request
    static func stubWithFixture(_ fixtureName: String, condition: @escaping HTTPStubsTestBlock) {
        stub(condition: condition) { _ in
            return Stubs.fixtureResponse(fixtureName)
        }
    }

    /// Loads a JSON fixture file and returns an HTTPStubsResponse
    /// - Parameter name: Name of the JSON file (without .json extension)
    /// - Returns: HTTPStubsResponse with the JSON content, or an error response if the file is not found
    private static func fixtureResponse(_ name: String) -> HTTPStubsResponse {
        // Use the same bundle marker as FixtureLoader for consistency
        let bundle = Bundle(for: AnyTestBundleMarker.self)

        guard let url = bundle.url(forResource: name, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data)
        else {
            return HTTPStubsResponse(
                error: NSError(
                    domain: "Tests",
                    code: 404,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Fixture \(name).json not found"
                    ]
                )
            )
        }

        return HTTPStubsResponse(jsonObject: json, statusCode: 200, headers: ["Content-Type": "application/json"])
    }
}
