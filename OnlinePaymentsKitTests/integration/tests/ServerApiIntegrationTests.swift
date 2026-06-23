/*
 * Do not remove or alter the notices in this preamble.
 *
 * This software is owned by Worldline and may not be be altered, copied, reproduced, republished, uploaded, posted, transmitted or distributed in any way, without the prior written consent of Worldline.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import XCTest

/// Integration tests for server API calls used by the SDK integration tests.
class ServerApiIntegrationTests: XCTestCase {

    var serverApi: ServerApiUtility!

    override func setUp() {
        super.setUp()

        loadEnvironmentFromFile()

        guard
            let apiKey = ProcessInfo.processInfo.environment["WORLDLINE_API_KEY"],
            let apiSecret = ProcessInfo.processInfo.environment["WORLDLINE_API_SECRET"],
            let baseUrl = ProcessInfo.processInfo.environment["WORLDLINE_BASE_URL"],
            let merchantId = ProcessInfo.processInfo.environment["WORLDLINE_MERCHANT_ID"]
        else {
            return
        }

        serverApi = ServerApiUtility(
            apiKey: apiKey,
            apiSecret: apiSecret,
            baseUrl: baseUrl,
            merchantId: merchantId
        )
    }

    func testServerApiSession() throws {
        try XCTSkipIf(serverApi == nil, "Skipping integration test - server API credentials are not configured")

        let expectation = expectation(description: "Create session")

        let request = CreateSessionRequest(tokens: nil)

        serverApi.createSession(request: request) { result in
            switch result {
            case .success(let response):
                XCTAssertNotNil(response.clientSessionId, "Client session ID should be present")
                XCTAssertNotNil(response.clientApiUrl, "Client API URL should be present")
                XCTAssertNotNil(response.assetUrl, "Asset URL should be present")
                XCTAssertNotNil(response.customerId, "Customer ID should be present")

            case .failure(let error):
                XCTFail("Failed to create session: \(error.localizedDescription)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 10.0)
    }

    func testServerApiSignatureGeneration() throws {
        let testUtility = ServerApiUtility(
            apiKey: "test-key",
            apiSecret: "test-secret",
            baseUrl: "https://test.example.com",
            merchantId: "12345"
        )

        let signature = try testUtility.generateSignature(
            method: "POST",
            contentType: "application/json; charset=utf-8",
            date: "Tue, 23 Jun 2026 10:00:00 GMT",
            canonicalizedHeaders: "",
            canonicalizedResource: "/v2/12345/sessions"
        )

        XCTAssertEqual(
            "x74QxgmfkUkArtKidCHM9EyyG5rnYpqqoJUDOfDV2s8=",
            signature,
            "Signature should match the expected HMAC-SHA256 Base64 value"
        )
    }

    private func loadEnvironmentFromFile() {
        let fileManager = FileManager.default

        let sourceFile = URL(fileURLWithPath: #filePath)
        let integrationDir = sourceFile.deletingLastPathComponent().path
        let envPath = "\(integrationDir)/.env"

        guard
            fileManager.fileExists(atPath: envPath),
            let contents = try? String(contentsOfFile: envPath, encoding: .utf8)
        else {
            return
        }

        contents.split(separator: "\n").forEach { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else {
                return
            }

            let parts = trimmed.split(separator: "=", maxSplits: 1)

            guard parts.count == 2 else {
                return
            }

            let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
            let value = String(parts[1]).trimmingCharacters(in: .whitespaces)

            if ProcessInfo.processInfo.environment[key] == nil {
                setenv(key, value, 1)
            }
        }
    }
}
