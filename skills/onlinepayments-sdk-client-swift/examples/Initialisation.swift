import Foundation
import OnlinePaymentsKit

// [START initialise-sdk]
/// Creates the SDK for one checkout. The session data comes from your backend (Create Session); never put the
/// API key or secret in the app. Keep the returned instance until the checkout ends, then drop every reference.
func makeSdk() async throws -> OnlinePaymentsSdk {
    let sessionData = try await fetchSessionData()

    let configuration = SdkConfiguration(
        appIdentifier: "MyShop/1.0", // your app's name and version
        loggingEnabled: false // never true in a release build
    )

    // Throws a ConfigurationError when a session value is empty or clientApiUrl is not a valid URL.
    return try OnlinePaymentsSdk(sessionData: sessionData, configuration: configuration)
}
// [END initialise-sdk]

// [START payment-context]
/// The order being paid. The payment context must hold the real values of this order.
struct Order {
    let orderId: String
    let amountInCents: Int // for example 1298 for 12.98 EUR
    let currencyCode: String // ISO 4217, for example "EUR"
    let countryCode: String // ISO 3166-1 alpha-2, for example "NL"
}

func makePaymentContext(for order: Order) -> PaymentContext {
    PaymentContext(
        amountOfMoney: AmountOfMoney(amount: order.amountInCents, currencyCode: order.currencyCode),
        isRecurring: false,
        countryCode: order.countryCode
    )
}
// [END payment-context]
