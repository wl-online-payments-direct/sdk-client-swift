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

internal class SessionNormalizer {

    internal static let kApiBase = "client/"

    static func normalize(_ sessionData: SessionData) throws -> SessionData {
        try validateRequiredFields(sessionData)

        let fixedUrl = try fixURL(url: sessionData.clientApiUrl)

        return SessionData(
            clientSessionId: sessionData.clientSessionId,
            customerId: sessionData.customerId,
            clientApiUrl: fixedUrl,
            assetUrl: sessionData.assetUrl
        )
    }

    private static func validateRequiredFields(_ sessionData: SessionData) throws {
        let fields: [(String, String?)] = [
            ("customerId", sessionData.customerId),
            ("assetUrl", sessionData.assetUrl),
            ("clientSessionId", sessionData.clientSessionId),
            ("clientApiUrl", sessionData.clientApiUrl),
        ]

        for (key, value) in fields {
            guard let value = value, !value.isEmpty else {
                throw ConfigurationError(
                    message: "The SessionData parameter '\(key)' is mandatory."
                )
            }
        }
    }

    private static func fixURL(url: String) throws -> String {
        guard var finalComponents = URLComponents(string: url) else {
            throw ConfigurationError(
                message: "A valid URL is required for the 'clientApiUrl', you provided '\(url)'"
            )
        }

        if !finalComponents.path.hasSuffix("/") {
            finalComponents.path += "/"
        }

        if !finalComponents.path.lowercased().hasSuffix(kApiBase) {
            finalComponents.path += kApiBase
        }

        guard let fixedUrl = finalComponents.url?.absoluteString else {
            throw ConfigurationError(
                message: "Failed to construct valid URL from '\(url)'"
            )
        }

        return fixedUrl
    }
}
