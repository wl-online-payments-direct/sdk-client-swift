# Error handling

Every SDK method reports a failure through its `failure` closure with an `SdkError`. The methods that
throw (`OnlinePaymentsSdk(sessionData:configuration:)`, `PaymentRequest.field(id:)`, `setValue(...)` and
`validate()`) throw an `SdkError` subclass as well. `SdkError` is an `NSObject` that conforms to `Error`.
It has a `message`, a `code` (`SdkErrorType`) and `metadata` (a dictionary). `ResponseError` also has
`httpStatusCode`. The class tells the errors apart: `ResponseError` and `CommunicationError` both have
the code `.clientError`.

| Error | When | What to do |
|---|---|---|
| `InvalidArgumentError` | Invalid input: `encryptPaymentRequest` with a request that does not validate (`metadata["errors"]` lists the validation errors), `setValue` on a field that is read-only for the stored card, `field(id:)` with an id the product does not have | Show validation errors; fix the calling code for the other cases |
| `CommunicationError` | No response, a network error, or a response that could not be read (a response that cannot be decoded is reported this way too) | Let the customer retry |
| `ResponseError` | The Client API returned an error response. `httpStatusCode` is set; `metadata["errorId"]` and `metadata["errors"]` (each with a `code`) describe it. Also created without a request, with `httpStatusCode` 404, when no payment product is available or for a product the SDK cannot process | HTTP status 404: not available (the card, payment method or currency conversion offer); do not restart, tell the customer or continue without the offer. Any other status: get new session data, create a new `OnlinePaymentsSdk` and restart the checkout |
| `EncryptionError` | Encryption failed, or `encryptTokenRequest` without a payment product id | Restart the checkout |
| `ConfigurationError` | `OnlinePaymentsSdk(sessionData:...)` with an empty session value or a `clientApiUrl` that is not a valid URL | Fix the integration |

`iinDetails` needs different handling for two cases, because it does not fail for them: below 6 digits it
calls `success` with the status `.notEnoughDigits`, and for a card number that matches no payment product
of your account (the API answers HTTP 404) it calls `success` with `.unknown`. Do not block the form on
`.unknown`. Every other API error, for example an expired session, calls `failure` with a `ResponseError`
(see [flows.md](flows.md#5-detect-the-card-brand)).

A card that cannot be converted gets no offer: `currencyConversionQuote` succeeds with a result other than
`.allowed`, or fails with a `ResponseError` with HTTP status 404. For a card without a surcharge, the
surcharge request succeeds with `.noSurcharge` (see [flows.md](flows.md#7-surcharge-and-currency-conversion-optional)).

Pass the payment product id of `surchargeCalculation` and `currencyConversionQuote` as an `NSNumber` (the
examples take an `Int?` and wrap it). The closure of a call that needs no request (a cached result, fewer
than 6 digits, an unsupported product) runs synchronously, before the method returns.

<!-- region: handle-sdk-error -->
```swift
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
```

The validation errors inside an `InvalidArgumentError` from `encryptPaymentRequest`:

<!-- region: invalid-argument-details -->
```swift
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
```

Rules:

- Log only `errorId`, error codes and HTTP status codes. Never log `PaymentRequest` values, form
  values or the `metadata` of an `InvalidArgumentError`. This includes crash reporting tools and loggers that capture console output.
- A failed SDK call never means a payment failed or succeeded. The payment result comes only from
  your backend.
- If the `OnlinePaymentsSdk` instance is released while a request is running, neither closure runs. Keep
  the instance until the checkout ends.
