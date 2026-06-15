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

class SessionNormalizerTestCase: XCTestCase {

    func testNormalizeAppendsClientSuffixToUrlWithoutPath() throws {
        let sessionData = SessionData(
            clientSessionId: "test-session",
            customerId: "test-customer",
            clientApiUrl: "https://api.example.com",
            assetUrl: "https://assets.example.com"
        )

        let normalized = try SessionNormalizer.normalize(sessionData)

        XCTAssertEqual(normalized.clientApiUrl, "https://api.example.com/client/")
    }

    func testNormalizeKeepsClientApiUrlWhenPathAlreadyHasClient() throws {
        let sessionData = SessionData(
            clientSessionId: "test-session",
            customerId: "test-customer",
            clientApiUrl: "https://api.example.com/client",
            assetUrl: "https://assets.example.com"
        )

        let normalized = try SessionNormalizer.normalize(sessionData)

        XCTAssertEqual(normalized.clientApiUrl, "https://api.example.com/client/")
    }

    func testNormalizeKeepsClientApiUrlWhenPathAlreadyHasClientWithTrailingSlash() throws {
        let sessionData = SessionData(
            clientSessionId: "test-session",
            customerId: "test-customer",
            clientApiUrl: "https://api.example.com/client/",
            assetUrl: "https://assets.example.com"
        )

        let normalized = try SessionNormalizer.normalize(sessionData)

        XCTAssertEqual(normalized.clientApiUrl, "https://api.example.com/client/")
    }

    func testNormalizeReturnsCopyWithoutMutatingOriginal() throws {
        let originalUrl = "https://api.example.com"
        let sessionData = SessionData(
            clientSessionId: "test-session",
            customerId: "test-customer",
            clientApiUrl: originalUrl,
            assetUrl: "https://assets.example.com"
        )

        let normalized = try SessionNormalizer.normalize(sessionData)

        XCTAssertNotEqual(normalized.clientApiUrl, originalUrl)
        XCTAssertEqual(sessionData.clientApiUrl, originalUrl)
    }

    func testNormalizePreservesNonUrlProperties() throws {
        let sessionData = SessionData(
            clientSessionId: "my-session-id",
            customerId: "my-customer-id",
            clientApiUrl: "https://api.example.com",
            assetUrl: "https://assets.example.com"
        )

        let normalized = try SessionNormalizer.normalize(sessionData)

        XCTAssertEqual(normalized.clientSessionId, "my-session-id")
        XCTAssertEqual(normalized.customerId, "my-customer-id")
        XCTAssertEqual(normalized.assetUrl, "https://assets.example.com")
    }

    func testNormalizeMissingCustomerIdThrowsConfigurationError() {
        let sessionData = SessionData(
            clientSessionId: "test-session",
            customerId: "",
            clientApiUrl: "https://api.example.com",
            assetUrl: "https://assets.example.com"
        )

        XCTAssertThrowsError(try SessionNormalizer.normalize(sessionData)) { error in
            XCTAssertTrue(error is ConfigurationError)
            XCTAssertTrue((error as? ConfigurationError)?.message.contains("customerId") ?? false)
        }
    }

    func testNormalizeMissingAssetUrlThrowsConfigurationError() {
        let sessionData = SessionData(
            clientSessionId: "test-session",
            customerId: "test-customer",
            clientApiUrl: "https://api.example.com",
            assetUrl: ""
        )

        XCTAssertThrowsError(try SessionNormalizer.normalize(sessionData)) { error in
            XCTAssertTrue(error is ConfigurationError)
            XCTAssertTrue((error as? ConfigurationError)?.message.contains("assetUrl") ?? false)
        }
    }

    func testNormalizeMissingClientSessionIdThrowsConfigurationError() {
        let sessionData = SessionData(
            clientSessionId: "",
            customerId: "test-customer",
            clientApiUrl: "https://api.example.com",
            assetUrl: "https://assets.example.com"
        )

        XCTAssertThrowsError(try SessionNormalizer.normalize(sessionData)) { error in
            XCTAssertTrue(error is ConfigurationError)
            XCTAssertTrue((error as? ConfigurationError)?.message.contains("clientSessionId") ?? false)
        }
    }

    func testNormalizeMissingClientApiUrlThrowsConfigurationError() {
        let sessionData = SessionData(
            clientSessionId: "test-session",
            customerId: "test-customer",
            clientApiUrl: "",
            assetUrl: "https://assets.example.com"
        )

        XCTAssertThrowsError(try SessionNormalizer.normalize(sessionData)) { error in
            XCTAssertTrue(error is ConfigurationError)
            XCTAssertTrue((error as? ConfigurationError)?.message.contains("clientApiUrl") ?? false)
        }
    }

    func testNormalizeInvalidClientApiUrlThrowsConfigurationError() {
        let sessionData = SessionData(
            clientSessionId: "test-session",
            customerId: "test-customer",
            clientApiUrl: "https://[invalid",
            assetUrl: "https://assets.example.com"
        )

        XCTAssertThrowsError(try SessionNormalizer.normalize(sessionData)) { error in
            XCTAssertTrue(error is ConfigurationError)
        }
    }
}
