import Foundation
import OnlinePaymentsKit

// [START async-wrappers]
// The SDK reports every result through a success or a failure closure, exactly once. These wrappers turn that
// into async/await. They need the OnlinePaymentsSdk instance to stay alive until the closure has been called:
// if it is released while a request runs, the closures never run and the awaiting task never resumes.
extension OnlinePaymentsSdk {
    func fetchBasicPaymentProducts(context: PaymentContext) async throws -> BasicPaymentProducts {
        try await withCheckedThrowingContinuation { continuation in
            basicPaymentProducts(
                forContext: context,
                success: { continuation.resume(returning: $0) },
                failure: { continuation.resume(throwing: $0) }
            )
        }
    }

    func fetchPaymentProduct(withId productId: Int, context: PaymentContext) async throws -> PaymentProduct {
        try await withCheckedThrowingContinuation { continuation in
            paymentProduct(
                withId: productId,
                paymentContext: context,
                success: { continuation.resume(returning: $0) },
                failure: { continuation.resume(throwing: $0) }
            )
        }
    }

    func fetchIinDetails(partialCardNumber: String, context: PaymentContext) async throws -> IINDetailsResponse {
        try await withCheckedThrowingContinuation { continuation in
            iinDetails(
                forPartialCardNumber: partialCardNumber,
                paymentContext: context,
                success: { continuation.resume(returning: $0) },
                failure: { continuation.resume(throwing: $0) }
            )
        }
    }

    func fetchSurcharge(
        amount: AmountOfMoney,
        partialCardNumber: String,
        paymentProductId: Int?
    ) async throws -> SurchargeCalculationResponse {
        try await withCheckedThrowingContinuation { continuation in
            surchargeCalculation(
                amountOfMoney: amount,
                partialCardNumber: partialCardNumber,
                paymentProductId: paymentProductId.map { NSNumber(value: $0) },
                success: { continuation.resume(returning: $0) },
                failure: { continuation.resume(throwing: $0) }
            )
        }
    }

    func fetchSurcharge(amount: AmountOfMoney, token: String) async throws -> SurchargeCalculationResponse {
        try await withCheckedThrowingContinuation { continuation in
            surchargeCalculation(
                amountOfMoney: amount,
                token: token,
                success: { continuation.resume(returning: $0) },
                failure: { continuation.resume(throwing: $0) }
            )
        }
    }

    func fetchCurrencyConversionQuote(
        amount: AmountOfMoney,
        partialCardNumber: String,
        paymentProductId: Int?
    ) async throws -> CurrencyConversionResponse {
        try await withCheckedThrowingContinuation { continuation in
            currencyConversionQuote(
                amountOfMoney: amount,
                partialCardNumber: partialCardNumber,
                paymentProductId: paymentProductId.map { NSNumber(value: $0) },
                success: { continuation.resume(returning: $0) },
                failure: { continuation.resume(throwing: $0) }
            )
        }
    }

    func fetchCurrencyConversionQuote(amount: AmountOfMoney, token: String) async throws -> CurrencyConversionResponse {
        try await withCheckedThrowingContinuation { continuation in
            currencyConversionQuote(
                amountOfMoney: amount,
                token: token,
                success: { continuation.resume(returning: $0) },
                failure: { continuation.resume(throwing: $0) }
            )
        }
    }

    func encrypt(_ request: PaymentRequest) async throws -> EncryptedRequest {
        try await withCheckedThrowingContinuation { continuation in
            encryptPaymentRequest(
                request,
                success: { continuation.resume(returning: $0) },
                failure: { continuation.resume(throwing: $0) }
            )
        }
    }

    func encrypt(_ request: CreditCardTokenRequest) async throws -> EncryptedRequest {
        try await withCheckedThrowingContinuation { continuation in
            encryptTokenRequest(
                request,
                success: { continuation.resume(returning: $0) },
                failure: { continuation.resume(throwing: $0) }
            )
        }
    }
}
// [END async-wrappers]
