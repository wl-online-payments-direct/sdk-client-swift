import Foundation
import OnlinePaymentsKit

// [START iin-details]
/// What the card number entered so far tells you.
enum CardLookup {
    case product(id: Int, coBrandIds: [Int]) // the card is accepted for this payment
    case notAccepted // a known card that is not allowed for this payment
    case unknown // no payment product of your account matches the card: do not block the form
    case needMoreDigits // fewer than 6 digits
}

func lookUpCard(sdk: OnlinePaymentsSdk, context: PaymentContext, enteredNumber: String) async throws -> CardLookup {
    // Fewer than 6 digits (spaces are ignored): no request is made and the status is .notEnoughDigits.
    // A card that matches no payment product (the API answers HTTP 404): the status is .unknown.
    // Neither case is an error. Every other API error, for example an expired session, is thrown as a
    // ResponseError: restart the checkout (see ErrorHandling.swift).
    let response = try await sdk.fetchIinDetails(partialCardNumber: enteredNumber, context: context)

    if response.status == .notEnoughDigits {
        return .needMoreDigits
    }
    if response.status == .existingButNotAllowed {
        return .notAccepted
    }
    guard response.status == .supported, let productId = response.paymentProductId else {
        return .unknown
    }

    // A co-branded card has entries in coBrands: let the customer choose one of the allowed brands.
    let coBrandIds = response.coBrands.filter { $0.allowedInContext }.map { $0.paymentProductId }
    return .product(id: productId, coBrandIds: coBrandIds)
}
// [END iin-details]

// [START card-detector]
/// Runs one IIN lookup at a time. The SDK does not reject a second lookup while one is running, and the answers
/// can arrive in any order, so only the lookup for the latest input may update the screen.
@MainActor
final class CardDetector {
    private let sdk: OnlinePaymentsSdk
    private let context: PaymentContext
    private let onResult: (Result<CardLookup, Error>) -> Void
    private var latestInput = ""
    private var isRunning = false

    init(sdk: OnlinePaymentsSdk, context: PaymentContext, onResult: @escaping (Result<CardLookup, Error>) -> Void) {
        self.sdk = sdk
        self.context = context
        self.onResult = onResult
    }

    /// Call whenever the card number field changes.
    func cardNumberChanged(_ cardNumber: String) {
        latestInput = cardNumber
        guard !isRunning else {
            return
        }

        isRunning = true
        Task { await runLookups() }
    }

    private func runLookups() async {
        defer { isRunning = false }

        while true {
            let lookedUp = latestInput
            do {
                let lookup = try await lookUpCard(sdk: sdk, context: context, enteredNumber: lookedUp)
                if lookedUp == latestInput {
                    onResult(.success(lookup))
                }
            } catch {
                if lookedUp == latestInput {
                    onResult(.failure(error))
                }
            }

            // The customer typed more while the lookup ran: look up the latest input.
            if lookedUp == latestInput {
                return
            }
        }
    }
}
// [END card-detector]
