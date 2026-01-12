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

/// Base class for integration tests.
/// Sets up the SDK with real session data and provides common test utilities.
class BaseIntegrationTest: XCTestCase {

    var sdk: OnlinePaymentsSdk!
    var paymentContext: PaymentContext!
    var serverApi: ServerApiUtility!

    /// Cached session to avoid excessive API calls
    private static var cachedSession: SessionData?
    private static var cacheTimestamp: Date?
    private static let cacheDuration: TimeInterval = 30 * 60  // 30 minutes

    /// Shared server API utility for creating sessions and other server operations
    private static var sharedServerApi: ServerApiUtility?

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Skip if credentials not configured
        guard isConfigured() else {
            throw XCTSkip("Skipping integration test - credentials not configured!")
        }

        // Initialize server API utility (for tests that need it)
        serverApi = try getServerApiUtility()

        // Get session data (cached)
        let sessionData = try getCachedSession()

        // Create SDK configuration
        let sdkConfiguration = SdkConfiguration(
            appIdentifier: "SwiftSDK/IntegrationTests"
        )

        // Initialize SDK
        sdk = try OnlinePaymentsSdk(
            sessionData: sessionData,
            configuration: sdkConfiguration
        )

        // Create default payment context
        paymentContext = createPaymentContext(amount: 1000)
    }

    override func tearDown() {
        sdk = nil
        paymentContext = nil
        serverApi = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    /// Create a payment context with custom amount
    func createPaymentContext(
        amount: Int,
        currencyCode: String = "EUR",
        countryCode: String = "NL"
    ) -> PaymentContext {
        return PaymentContext(
            amountOfMoney: AmountOfMoney(
                amount: amount,
                currencyCode: currencyCode
            ),
            isRecurring: false,
            countryCode: countryCode
        )
    }

    // MARK: - Session Management

    /// Check if credentials are configured
    private func isConfigured() -> Bool {
        loadEnvironmentFromFile()

        guard ProcessInfo.processInfo.environment["WORLDLINE_API_KEY"] != nil,
            ProcessInfo.processInfo.environment["WORLDLINE_API_SECRET"] != nil,
            ProcessInfo.processInfo.environment["WORLDLINE_BASE_URL"] != nil,
            ProcessInfo.processInfo.environment["WORLDLINE_MERCHANT_ID"] != nil
        else {
            return false
        }

        return true
    }

    /// Get cached session or create a new one
    private func getCachedSession() throws -> SessionData {
        let now = Date()

        // Check if cache is valid
        if let cached = Self.cachedSession,
            let timestamp = Self.cacheTimestamp,
            now.timeIntervalSince(timestamp) < Self.cacheDuration
        {
            return cached
        }

        // Create new session
        let session = try createSession()
        Self.cachedSession = session
        Self.cacheTimestamp = now

        return session
    }

    /// Get or create ServerApiUtility
    private func getServerApiUtility() throws -> ServerApiUtility {
        // Return shared instance if available
        if let existing = Self.sharedServerApi {
            return existing
        }

        // Create new instance
        guard let apiKey = ProcessInfo.processInfo.environment["WORLDLINE_API_KEY"],
            let apiSecret = ProcessInfo.processInfo.environment["WORLDLINE_API_SECRET"],
            let baseUrl = ProcessInfo.processInfo.environment["WORLDLINE_BASE_URL"],
            let merchantId = ProcessInfo.processInfo.environment["WORLDLINE_MERCHANT_ID"]
        else {
            throw NSError(
                domain: "BaseIntegrationTest",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Missing credentials"]
            )
        }

        let serverApi = ServerApiUtility(
            apiKey: apiKey,
            apiSecret: apiSecret,
            baseUrl: baseUrl,
            merchantId: merchantId
        )

        Self.sharedServerApi = serverApi
        return serverApi
    }

    /// Create a new session using ServerApiUtility
    private func createSession() throws -> SessionData {
        let expectation = XCTestExpectation(description: "Create session")
        var result: Result<CreateSessionResponse, Error>?

        // Get server API utility
        let serverApi = try getServerApiUtility()

        // Create session
        let request = CreateSessionRequest(tokens: nil)
        serverApi.createSession(request: request) { response in
            result = response
            expectation.fulfill()
        }

        let waiter = XCTWaiter()
        let waitResult = waiter.wait(for: [expectation], timeout: 10.0)

        guard waitResult == .completed else {
            throw NSError(
                domain: "BaseIntegrationTest",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Session creation timed out"]
            )
        }

        switch result {
        case .success(let response):
            guard let clientSessionId = response.clientSessionId,
                let customerId = response.customerId,
                let clientApiUrl = response.clientApiUrl,
                let assetUrl = response.assetUrl
            else {
                throw NSError(
                    domain: "BaseIntegrationTest",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid session response"]
                )
            }

            return SessionData(
                clientSessionId: clientSessionId,
                customerId: customerId,
                clientApiUrl: clientApiUrl,
                assetUrl: assetUrl
            )

        case .failure(let error):
            throw error

        case .none:
            throw NSError(
                domain: "BaseIntegrationTest",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No result from session creation"]
            )
        }
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
}
