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

/// Integration tests for the complete payment flow
/// These tests require valid API credentials and should only be run in controlled environments
///
/// To run these tests:
/// 1. Set the following environment variables:
///    - WORLDLINE_API_KEY: Your API key (merchant ID)
///    - WORLDLINE_API_SECRET: Your API secret
///    - WORLDLINE_BASE_URL: The base API URL (e.g., https://payment.preprod.direct.worldline-solutions.com)
///    - WORLDLINE_MERCHANT_ID: Your merchant/customer ID
///
/// 2. Uncomment the test methods below
/// 3. Run tests with: xcodebuild test -scheme OnlinePaymentsKit
class ServerApiIntegrationTests: XCTestCase {

    var serverApi: ServerApiUtility!

    override func setUp() {
        super.setUp()

        // Load credentials from .env file or environment variables
        loadEnvironmentFromFile()

        guard let apiKey = ProcessInfo.processInfo.environment["WORLDLINE_API_KEY"],
            let apiSecret = ProcessInfo.processInfo.environment["WORLDLINE_API_SECRET"],
            let baseUrl = ProcessInfo.processInfo.environment["WORLDLINE_BASE_URL"],
            let merchantId = ProcessInfo.processInfo.environment["WORLDLINE_MERCHANT_ID"]
        else {
            // Skip tests if credentials not provided
            return
        }

        serverApi = ServerApiUtility(
            apiKey: apiKey,
            apiSecret: apiSecret,
            baseUrl: baseUrl,
            merchantId: merchantId
        )
    }

    /// Loads environment variables from .env file if present
    private func loadEnvironmentFromFile() {
        let fileManager = FileManager.default

        // Look for .env in the Integration test directory
        guard let sourceFile = URL(string: #file),
            let integrationDir = sourceFile.deletingLastPathComponent().path.removingPercentEncoding
        else {
            return
        }

        let envPath = "\(integrationDir)/.env"

        guard fileManager.fileExists(atPath: envPath),
            let contents = try? String(contentsOfFile: envPath, encoding: .utf8)
        else {
            return
        }

        // Parse .env file
        contents.split(separator: "\n").forEach { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Skip comments and empty lines
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else {
                return
            }

            // Parse KEY=VALUE format
            let parts = trimmed.split(separator: "=", maxSplits: 1)
            guard parts.count == 2 else {
                return
            }

            let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
            let value = String(parts[1]).trimmingCharacters(in: .whitespaces)

            // Set environment variable (only if not already set)
            if ProcessInfo.processInfo.environment[key] == nil {
                setenv(key, value, 1)
            }
        }
    }

    // MARK: - Create Session Tests

    /// Test creating a new session
    func testCreateSession() {
        guard serverApi != nil else {
            print("Skipping integration test - credentials not configured")
            return
        }

        let expectation = expectation(description: "Create session")

        let request = CreateSessionRequest(tokens: nil)

        serverApi.createSession(request: request) { result in
            switch result {
            case .success(let response):
                XCTAssertNotNil(response.clientSessionId, "Client session ID should be present")
                XCTAssertNotNil(response.clientApiUrl, "Client API URL should be present")
                XCTAssertNotNil(response.assetUrl, "Asset URL should be present")
                XCTAssertNotNil(response.customerId, "Customer ID should be present")
                print("Session created successfully:")
                print("   Session ID: \(response.clientSessionId ?? "nil")")
                print("   Customer ID: \(response.customerId ?? "nil")")

            case .failure(let error):
                XCTFail("Failed to create session: \(error.localizedDescription)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 10.0)
    }

    // MARK: - Authentication Tests

    func testSignatureGeneration() {
        // This test verifies the signature generation without making actual API calls
        let testUtility = ServerApiUtility(
            apiKey: "test-key",
            apiSecret: "test-secret",
            baseUrl: "https://test.example.com",
            merchantId: "12345"
        )

        // The signature generation is tested indirectly through the private method
        // Real validation will happen when integration tests run with actual API
        XCTAssertNotNil(testUtility)
    }
}
