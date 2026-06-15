/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

/// Centralised test constants used across unit and integration tests.
///
/// Using named constants avoids duplicated magic strings and makes it easy to keep expiry dates
/// far in the future as time passes.
enum TestData {
    /// Standard Visa test card number used in encryption and facade tests.
    static let visaCardNumber = "4242424242424242"

    /// Alternative Visa card used in PaymentRequest integration flow tests.
    static let visaCardNumberAlt = "4567350000427977"

    /// A card number that is considered invalid for format-validation tests.
    static let invalidCardNumber = "4222422242224222"

    /// Standard CVV used across tests where the actual value doesn't matter.
    static let cvv = "123"

    /// Far-future expiry date in MMYY format (no separator), used for PaymentRequest fields.
    static let expiryDateMMYY = "1230"

    /// Far-future expiry date with slash separator (MM/YYYY), used for EncryptionService tests.
    static let expiryDateSlash = "12/2030"
}
