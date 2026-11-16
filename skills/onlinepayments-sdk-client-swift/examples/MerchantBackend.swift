import Foundation
import OnlinePaymentsKit

// [START merchant-backend]
// The URL, paths and JSON shapes are placeholders for your own backend; the SDK never calls them.
private let backendUrl = "https://shop.example.com"

/// The payment status as your backend reports it.
enum PaymentStatus: String, Decodable {
    case success = "SUCCESS"
    case pending = "PENDING"
    case failed = "FAILED"
}

/// What your backend returns after it created the payment, or when the app asks for the status.
struct MerchantPaymentResponse: Decodable {
    let status: PaymentStatus
    /// Set when the customer must be redirected, for example for 3-D Secure.
    let redirectUrl: String?
}

/// The customer's currency conversion choice. Your backend passes both fields to Create Payment in
/// cardPaymentMethodSpecificInput.currencyConversion. Both are mandatory once a quote was shown.
struct CurrencyConversionChoice {
    let dccSessionId: String
    /// true: pay in the card's currency; false: pay in your currency.
    let acceptedByUser: Bool
}

enum MerchantBackendError: Error {
    case invalidUrl
    case httpStatus(Int)
}

private struct SessionResponse: Decodable {
    let clientSessionId: String
    let customerId: String
    let clientApiUrl: String
    let assetUrl: String
}

private struct TokenResponse: Decodable {
    let token: String
}

// Never log the body you send: it holds the encrypted customer input.
private func postJson(path: String, body: [String: Any] = [:]) async throws -> Data {
    guard let url = URL(string: backendUrl + path) else {
        throw MerchantBackendError.invalidUrl
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (data, response) = try await URLSession.shared.data(for: request)
    if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
        throw MerchantBackendError.httpStatus(httpResponse.statusCode)
    }

    return data
}

/// Your backend creates a new client session for this checkout (Create Session) and returns its data.
func fetchSessionData() async throws -> SessionData {
    let data = try await postJson(path: "/api/checkout/session")
    let session = try JSONDecoder().decode(SessionResponse.self, from: data)

    return SessionData(
        clientSessionId: session.clientSessionId,
        customerId: session.customerId,
        clientApiUrl: session.clientApiUrl,
        assetUrl: session.assetUrl
    )
}

/// Your backend creates the payment (Create Payment) with the encrypted customer input.
func submitEncryptedPayment(
    orderId: String,
    encryptedRequest: EncryptedRequest,
    currencyConversion: CurrencyConversionChoice? = nil // only when a currency conversion offer was shown
) async throws -> MerchantPaymentResponse {
    var body: [String: Any] = [
        "orderId": orderId,
        "encryptedCustomerInput": encryptedRequest.encryptedCustomerInput,
        "encodedClientMetaInfo": encryptedRequest.encodedClientMetaInfo
    ]
    if let currencyConversion = currencyConversion {
        let choice: [String: Any] = [
            "dccSessionId": currencyConversion.dccSessionId,
            "acceptedByUser": currencyConversion.acceptedByUser
        ]
        body["currencyConversion"] = choice
    }

    let data = try await postJson(path: "/api/checkout/payment", body: body)
    return try JSONDecoder().decode(MerchantPaymentResponse.self, from: data)
}

/// Your backend reads the payment status, for example after the customer returned from 3-D Secure.
func fetchPaymentStatus(orderId: String) async throws -> MerchantPaymentResponse {
    let data = try await postJson(path: "/api/checkout/status", body: ["orderId": orderId])
    return try JSONDecoder().decode(MerchantPaymentResponse.self, from: data)
}

/// Your backend creates a payment token (Create Token) from the encrypted card data. Returns the token id.
func submitEncryptedToken(_ encryptedRequest: EncryptedRequest) async throws -> String {
    let body: [String: Any] = [
        "encryptedCustomerInput": encryptedRequest.encryptedCustomerInput,
        "encodedClientMetaInfo": encryptedRequest.encodedClientMetaInfo
    ]
    let data = try await postJson(path: "/api/checkout/token", body: body)
    return try JSONDecoder().decode(TokenResponse.self, from: data).token
}
// [END merchant-backend]
