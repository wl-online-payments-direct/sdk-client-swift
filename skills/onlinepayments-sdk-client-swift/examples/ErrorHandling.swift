import Foundation
import OnlinePaymentsKit
import os

// [START handle-sdk-error]
enum ErrorAction {
    case showValidationErrors // the customer can fix the input
    case retry // a network problem: the same call can be tried again
    case notAvailable // HTTP 404: the card, payment method or currency conversion offer is not available
    case restartCheckout // get new session data from your backend and create a new OnlinePaymentsSdk
    case integrationError // a bug in the integration: fix the code
}

private let checkoutLog = Logger(subsystem: "com.example.shop", category: "Checkout")

/// Classifies the error of an SDK call. Every SDK error is an SdkError, but its code does not tell a
/// ResponseError from a CommunicationError (both are .clientError): check the class.
func classifySdkError(_ error: Error) -> ErrorAction {
    if error is InvalidArgumentError {
        // encryptPaymentRequest with a request that does not validate (see invalid-argument-details), setValue on
        // a field that is read-only for the stored card, or field(id:) with an id the product does not have.
        return .showValidationErrors
    }

    if error is CommunicationError {
        // No response, a network error, or a response that could not be read.
        return .retry
    }

    if let responseError = error as? ResponseError {
        // The Client API returned an error, for example because the session is no longer valid, or HTTP status
        // 404 when no payment product is available. Log only the status code, the error id and the error codes.
        let errorId = responseError.metadata?["errorId"] as? String ?? ""
        let errors = responseError.metadata?["errors"] as? [[String: Any]] ?? []
        let codes = errors.compactMap { $0["code"] as? String }.joined(separator: ",")
        let status = responseError.httpStatusCode ?? 0
        checkoutLog.warning(
            "Client API error \(status, privacy: .public) \(errorId, privacy: .public) \(codes, privacy: .public)"
        )
        // HTTP 404: the card, payment method or currency conversion offer is not available. Do not restart: tell
        // the customer, or continue without the offer. Any other status: the session is no longer usable.
        return responseError.httpStatusCode == 404 ? .notAvailable : .restartCheckout
    }

    if error is EncryptionError {
        // Encryption failed, or encryptTokenRequest without a payment product id.
        return .restartCheckout
    }

    // ConfigurationError (an empty session value or an invalid clientApiUrl when the SDK is created) and
    // every other error.
    return .integrationError
}
// [END handle-sdk-error]

// [START invalid-argument-details]
struct FieldError {
    let fieldId: String
    let type: String // for example "RequiredField" or "LUHN"
}

/// The validation errors inside the InvalidArgumentError that encryptPaymentRequest throws for a request that
/// does not validate. Show them next to their fields. Do not log them.
func fieldErrors(from error: InvalidArgumentError) -> [FieldError] {
    let errors = error.metadata?["errors"] as? [[String: Any]] ?? []

    return errors.compactMap { entry in
        guard let fieldId = entry["paymentProductFieldId"] as? String else {
            return nil
        }

        return FieldError(fieldId: fieldId, type: entry["type"] as? String ?? "")
    }
}
// [END invalid-argument-details]

// [START restart-checkout]
/// Holds the SDK of the running checkout.
@MainActor
final class CheckoutSession {
    private(set) var sdk: OnlinePaymentsSdk?

    func start() async throws {
        sdk = try await makeSdk()
    }

    /// After a ResponseError other than HTTP 404 the session is no longer usable. Drop the old instance, get new
    /// session data and create a new SDK. Then load the payment product again and create a new PaymentRequest.
    /// Whether the customer's input is kept is your decision.
    func restart() async throws {
        sdk = nil
        sdk = try await makeSdk()
    }
}
// [END restart-checkout]
