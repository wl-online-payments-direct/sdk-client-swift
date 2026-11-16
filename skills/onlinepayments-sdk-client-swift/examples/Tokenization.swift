import Foundation
import OnlinePaymentsKit

enum TokenizationError: Error {
    case cardNotSupported
    case invalidInput(fieldIds: [String]) // the fields that failed validation
}

// [START tokenization-product]
/// Loads the card product for tokenization. There is no order amount, so the payment context uses an amount of 1,
/// the smallest unit of the currency (for example 1 cent for EUR). Do not use 0: the Client API answers an
/// amount of 0 with an error.
func loadProductForTokenization(
    sdk: OnlinePaymentsSdk,
    cardNumber: String,
    currencyCode: String,
    countryCode: String
) async throws -> PaymentProduct {
    let context = PaymentContext(
        amountOfMoney: AmountOfMoney(amount: 1, currencyCode: currencyCode),
        isRecurring: false,
        countryCode: countryCode
    )

    let iinDetails = try await sdk.fetchIinDetails(partialCardNumber: cardNumber, context: context)
    guard iinDetails.status == .supported, let productId = iinDetails.paymentProductId else {
        throw TokenizationError.cardNotSupported
    }

    return try await sdk.fetchPaymentProduct(withId: productId, context: context)
}
// [END tokenization-product]

// [START encrypt-token-request]
/// Stores a card without a payment. The token request applies no validation of its own, so the values are
/// validated with the product's fields first. A PaymentRequest removes the mask from the typed values; its
/// unmasked values go into the token request. Returns the token id that your backend created.
func tokenizeCard(
    sdk: OnlinePaymentsSdk,
    product: PaymentProduct,
    typedValues: [String: String] // field id to typed text, for example "cardNumber" and "expiryDate"
) async throws -> String {
    let validationRequest = PaymentRequest(paymentProduct: product)
    for (fieldId, typedText) in typedValues {
        try validationRequest.setValue(id: fieldId, value: typedText)
    }

    let validation = try validationRequest.validate()
    guard validation.isValid else {
        throw TokenizationError.invalidInput(fieldIds: validation.errors.compactMap { $0.paymentProductFieldId })
    }

    let tokenRequest = CreditCardTokenRequest(
        cardNumber: validationRequest.value(id: "cardNumber"),
        cardholderName: validationRequest.value(id: "cardholderName"),
        expiryDate: validationRequest.value(id: "expiryDate"),
        securityCode: validationRequest.value(id: "cvv"),
        paymentProductId: product.idValue // required: without it the encryption fails
    )

    let encryptedRequest = try await sdk.encrypt(tokenRequest)
    return try await submitEncryptedToken(encryptedRequest)
}
// [END encrypt-token-request]
