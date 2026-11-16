import Foundation
import OnlinePaymentsKit

// [START create-payment-request]
/// Create the request once the product is loaded. For a stored card pass its account on file. With saveCard
/// the platform stores the card as an account on file when the payment succeeds.
func makePaymentRequest(
    product: PaymentProduct,
    accountOnFile: AccountOnFile?,
    saveCard: Bool
) -> PaymentRequest {
    PaymentRequest(paymentProduct: product, accountOnFile: accountOnFile, tokenize: saveCard)
}
// [END create-payment-request]

// [START mask-input]
/// Call on every change of a text field. It stores what the customer typed (the SDK removes the mask itself)
/// and returns the text to show in the field. It throws an InvalidArgumentError for a field id the product does
/// not have, or for a field that is read-only for the stored card.
func updateField(_ request: PaymentRequest, fieldId: String, typedText: String) throws -> String {
    let field = try request.field(id: fieldId)
    try field.setValue(value: typedText)

    return field.maskedValue ?? ""
}
// [END mask-input]

// [START validate-field]
/// Validates one field, for example when the customer leaves it. An empty result means the value is valid.
func validateField(_ request: PaymentRequest, fieldId: String) throws -> [ValidationErrorMessage] {
    try request.field(id: fieldId).validate().errors
}
// [END validate-field]

// [START validate-payment-request]
/// Validates the whole request before encrypting it. Returns the errors per field id: show each one next to its
/// field. An empty result means the request can be encrypted.
func validateRequest(_ request: PaymentRequest) throws -> [String: [ValidationErrorMessage]] {
    let result = try request.validate()

    return Dictionary(grouping: result.errors) { $0.paymentProductFieldId ?? "" }
}
// [END validate-payment-request]

// [START validation-texts]
/// The SDK's errorMessage is English. To show your own translated texts, map the error's type.
func displayText(for error: ValidationErrorMessage) -> String {
    switch error.type ?? "" {
    case "RequiredField":
        return String(localized: "validation.required")
    case "LUHN":
        return String(localized: "validation.cardNumberInvalid")
    case "EXPIRATIONDATE":
        return String(localized: "validation.expiryDateInvalid")
    case "LENGTH":
        return String(localized: "validation.lengthInvalid")
    default:
        return error.errorMessage
    }
}
// [END validation-texts]

// [START string-formatter]
/// StringFormatter applies and removes a field's mask. PaymentRequestField does this for you (see mask-input);
/// use StringFormatter for values that are not stored in a PaymentRequest.
func formatWithMask(_ unmaskedValue: String, mask: String) -> String {
    StringFormatter().formatString(string: unmaskedValue, mask: mask)
}

func removeMask(from maskedValue: String, mask: String) -> String {
    StringFormatter().unformatString(string: maskedValue, mask: mask)
}
// [END string-formatter]
