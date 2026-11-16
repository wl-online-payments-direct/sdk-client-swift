import Foundation
import OnlinePaymentsKit

// [START get-payment-product]
/// Loads the full product with its fields. For a stored card, pass the account on file's paymentProductId.
func loadPaymentProduct(
    sdk: OnlinePaymentsSdk,
    productId: Int,
    context: PaymentContext
) async throws -> PaymentProduct {
    try await sdk.fetchPaymentProduct(withId: productId, context: context)
}
// [END get-payment-product]

// [START describe-form-fields]
/// What your UI needs to render one input. All of it comes from the payment product; do not hard-code
/// labels, masks or rules for a product.
struct FormField {
    let fieldId: String
    let label: String
    let placeholder: String?
    let mask: String? // for example "{{9999}} {{9999}} {{9999}} {{9999}}"
    let obfuscate: Bool // show the input as dots, like a password
    let isRequired: Bool
    let isEditable: Bool // false for the stored fields of an account on file
    let keyboard: PreferredInputType
    let storedValue: String? // the value stored in the account on file, for display only
}

/// Describes the form for a product, or for a stored card. For a stored card, load the product with the
/// account on file's paymentProductId. The fields are already sorted by their display order.
func describeFormFields(product: PaymentProduct, accountOnFile: AccountOnFile?) -> [FormField] {
    product.fields.map { field in
        FormField(
            fieldId: field.id,
            label: field.label,
            placeholder: field.placeholder,
            mask: field.displayHints.mask,
            obfuscate: field.shouldObfuscate,
            isRequired: field.isRequired,
            isEditable: accountOnFile?.isWritable(id: field.id) ?? true,
            keyboard: field.displayHints.preferredInputType,
            storedValue: accountOnFile?.getValue(id: field.id)
        )
    }
}
// [END describe-form-fields]
