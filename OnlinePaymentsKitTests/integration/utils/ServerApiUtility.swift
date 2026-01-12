/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import CryptoKit
import Foundation

/// Utility for making authenticated server API calls in integration tests
/// Implements "GCS v1HMAC" authentication as described in the API documentation
class ServerApiUtility {

    private let apiKey: String
    private let apiSecret: String
    private let baseUrl: String
    private let merchantId: String

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
        return formatter
    }()

    init(apiKey: String, apiSecret: String, baseUrl: String, merchantId: String) {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.baseUrl = baseUrl
        self.merchantId = merchantId
    }

    // MARK: - API Endpoints

    func createSession(
        request: CreateSessionRequest,
        completion: @escaping (Result<CreateSessionResponse, Error>) -> Void
    ) {
        let endpoint = "/v2/\(merchantId)/sessions"
        post(endpoint: endpoint, body: request, responseType: CreateSessionResponse.self, completion: completion)
    }

    func createToken(request: CreateTokenRequest, completion: @escaping (Result<CreateTokenResponse, Error>) -> Void) {
        let endpoint = "/v2/\(merchantId)/tokens"
        post(endpoint: endpoint, body: request, responseType: CreateTokenResponse.self, completion: completion)
    }

    func createPayment(
        request: CreatePaymentRequest,
        completion: @escaping (Result<CreatePaymentResponse, Error>) -> Void
    ) {
        let endpoint = "/v2/\(merchantId)/payments"
        post(endpoint: endpoint, body: request, responseType: CreatePaymentResponse.self, completion: completion)
    }

    // MARK: - HTTP Methods

    private func post<T: Encodable, R: Decodable>(
        endpoint: String,
        body: T,
        responseType: R.Type,
        completion: @escaping (Result<R, Error>) -> Void
    ) {
        do {
            let url = URL(string: baseUrl + endpoint)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let contentType = "application/json; charset=utf-8"
            let date = dateFormatter.string(from: Date())

            // Encode body to JSON
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(body)
            request.httpBody = jsonData

            // Generate signature
            let signature = try generateSignature(
                method: "POST",
                contentType: contentType,
                date: date,
                canonicalizedHeaders: "",
                canonicalizedResource: endpoint
            )

            // Set headers
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
            request.setValue(date, forHTTPHeaderField: "Date")
            request.setValue("GCS v1HMAC:\(apiKey):\(signature)", forHTTPHeaderField: "Authorization")

            // Make request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(ServerApiError.noData))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(ServerApiError.invalidResponse))
                    return
                }

                // Check for HTTP errors
                guard (200...299).contains(httpResponse.statusCode) else {
                    if let errorResponse = try? JSONDecoder().decode(ApiErrorResponse.self, from: data) {
                        completion(
                            .failure(
                                ServerApiError.apiError(statusCode: httpResponse.statusCode, response: errorResponse)
                            )
                        )
                    } else {
                        completion(.failure(ServerApiError.httpError(statusCode: httpResponse.statusCode)))
                    }
                    return
                }

                // Decode response
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(R.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }

            task.resume()

        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - Authentication

    /// Generates HMAC-SHA256 signature for GCS v1HMAC authentication
    /// String-to-hash format:
    /// ```
    /// POST
    /// application/json; charset=utf-8
    /// <RFC1123 Date>
    /// <CanonicalizedHeaders>
    /// /v2/<merchantId>/<endpoint>
    /// ```
    private func generateSignature(
        method: String,
        contentType: String,
        date: String,
        canonicalizedHeaders: String,
        canonicalizedResource: String
    ) throws -> String {
        // Build string-to-hash
        var stringToHash = "\(method)\n"
        stringToHash += "\(contentType)\n"
        stringToHash += "\(date)\n"

        if !canonicalizedHeaders.isEmpty {
            stringToHash += "\(canonicalizedHeaders)\n"
        }

        stringToHash += "\(canonicalizedResource)\n"

        // Calculate HMAC-SHA256
        guard let data = stringToHash.data(using: .utf8),
            let keyData = apiSecret.data(using: .utf8)
        else {
            throw ServerApiError.encodingError
        }

        let key = SymmetricKey(data: keyData)
        let signature = HMAC<SHA256>.authenticationCode(for: data, using: key)

        // Base64 encode
        let signatureData = Data(signature)
        return signatureData.base64EncodedString()
    }
}

// MARK: - Error Types

enum ServerApiError: Error, LocalizedError {
    case noData
    case invalidResponse
    case httpError(statusCode: Int)
    case apiError(statusCode: Int, response: ApiErrorResponse)
    case encodingError

    var errorDescription: String? {
        switch self {
        case .noData:
            return "No data received from server"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .apiError(let statusCode, let response):
            return
                "API error \(statusCode): \(response.errorId ?? "unknown") - \(response.errors?.first?.message ?? "no message")"
        case .encodingError:
            return "Failed to encode request data"
        }
    }
}

// MARK: - Request/Response Models

struct CreateSessionRequest: Codable {
    let tokens: [String]?

    init(tokens: [String]? = nil) {
        self.tokens = tokens
    }
}

struct CreateSessionResponse: Codable {
    let assetUrl: String?
    let clientApiUrl: String?
    let clientSessionId: String?
    let customerId: String?
    let invalidTokens: [String]?
}

struct CreateTokenRequest: Codable {
    let encryptedCustomerInput: String
}

struct CreateTokenResponse: Codable {
    let token: String?
    let isNewToken: Bool?
}

struct CreatePaymentRequest: Codable {
    let order: PaymentOrder
    let encryptedCustomerInput: String
}

struct PaymentOrder: Codable {
    let amountOfMoney: PaymentAmountOfMoney
    let customer: PaymentCustomer
}

struct PaymentAmountOfMoney: Codable {
    let amount: Int
    let currencyCode: String
}

struct PaymentCustomer: Codable {
    let billingAddress: PaymentAddress?
    let merchantCustomerId: String?
}

struct PaymentAddress: Codable {
    let countryCode: String?
    let city: String?
    let street: String?
    let zip: String?
}

struct CreatePaymentResponse: Codable {
    let payment: PaymentOutput?
}

struct PaymentOutput: Codable {
    let id: String?
    let status: String?
    let statusOutput: PaymentStatusOutput?
}

struct PaymentStatusOutput: Codable {
    let isCancellable: Bool?
    let statusCode: Int?
    let statusCodeChangeDateTime: String?
}

struct ApiErrorResponse: Codable {
    let errorId: String?
    let errors: [ApiErrorDetail]?
}

struct ApiErrorDetail: Codable {
    let code: String?
    let message: String?
    let propertyName: String?
}
