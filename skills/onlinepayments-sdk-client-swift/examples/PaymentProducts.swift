import Foundation
import OnlinePaymentsKit

// [START list-payment-products]
/// One row of the stored cards list.
struct StoredCardRow {
    let accountOnFileId: String
    let paymentProductId: Int
    let label: String
}

/// What the payment selection screen shows.
struct PaymentOptions {
    let products: [BasicPaymentProduct]
    let storedCards: [StoredCardRow]
}

/// The payment products and stored cards available for this order. The SDK already removes the products it
/// cannot process (Maestro 117 and three gift cards). It keeps Apple Pay (302) when the device can pay with it,
/// so remove it when your app does not implement Apple Pay. The SDK does not sort the products.
func loadPaymentOptions(sdk: OnlinePaymentsSdk, context: PaymentContext) async throws -> PaymentOptions {
    // Fails with a ResponseError (HTTP status 404) when no payment product is available.
    let response = try await sdk.fetchBasicPaymentProducts(context: context)

    let products = response.paymentProducts
        .filter { $0.id != 302 }
        .sorted { $0.displayOrder < $1.displayOrder }
    let productIds = Set(products.compactMap { $0.id })

    // Stored cards (accounts on file) are only returned when your backend passed the customer's tokens
    // to Create Session.
    let storedCards = response.accountsOnFile
        .filter { productIds.contains($0.paymentProductId) }
        .map { account in
            StoredCardRow(
                accountOnFileId: account.id,
                paymentProductId: account.paymentProductId,
                label: account.label ?? ""
            )
        }

    return PaymentOptions(products: products, storedCards: storedCards)
}
// [END list-payment-products]

// [START logo-url]
/// The URL of a payment product's logo. The SDK downloads the logo itself only when `logo` is a full URL
/// (then `getLogoImage()` returns it). When `logo` is a partial path, build the URL from the session's assetUrl.
func logoUrl(for product: BasicPaymentProduct, assetUrl: String) -> URL? {
    guard let logo = product.logo, !logo.isEmpty else {
        return nil
    }
    if let absoluteUrl = URL(string: logo), absoluteUrl.scheme != nil {
        return absoluteUrl
    }

    let base = assetUrl.hasSuffix("/") ? String(assetUrl.dropLast()) : assetUrl
    let path = logo.hasPrefix("/") ? logo : "/" + logo
    return URL(string: base + path)
}
// [END logo-url]
