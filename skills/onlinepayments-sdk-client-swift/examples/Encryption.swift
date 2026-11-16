import Foundation
import OnlinePaymentsKit

// [START encrypt-payment-request]
/// Encrypts the request on the device and sends the result to your backend. This is the only way card data
/// leaves the device. encrypt validates the request again and throws an InvalidArgumentError when it is not
/// valid. The result has two parts, encryptedCustomerInput and encodedClientMetaInfo: your backend passes
/// both to Create Payment.
func pay(
    sdk: OnlinePaymentsSdk,
    request: PaymentRequest,
    order: Order,
    currencyConversion: CurrencyConversionChoice?
) async throws -> MerchantPaymentResponse {
    let encryptedRequest = try await sdk.encrypt(request)

    return try await submitEncryptedPayment(
        orderId: order.orderId,
        encryptedRequest: encryptedRequest,
        currencyConversion: currencyConversion
    )
}
// [END encrypt-payment-request]
