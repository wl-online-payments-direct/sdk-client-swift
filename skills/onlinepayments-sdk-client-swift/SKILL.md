---
name: onlinepayments-sdk-client-swift
description: Build in-app card checkouts with the Online Payments Swift client SDK (Swift package and XCFramework OnlinePaymentsKit, class OnlinePaymentsSdk, iOS). Use when Swift or Objective-C code initialises OnlinePaymentsSdk from client session data, lists payment products or stored cards (accounts on file), renders payment product fields in UIKit or SwiftUI, detects the card brand (IIN details), validates or masks card input, encrypts a payment or token request, handles the 3-D Secure redirect and the return to the app through a universal link or URL scheme, or shows a surcharge or currency conversion offer.
---

# Online Payments Swift client SDK

This skill covers the app side of an Online Payments card checkout built with the iOS library
`OnlinePaymentsKit` (Swift package `sdk-client-swift`). The SDK runs in the app: it reads payment
products from the Client API, validates and formats customer input, and encrypts it. The encrypted
result is sent to your own backend, which creates the payment.

## How to use this skill

- Use the code in the reference files. Do not write calls to this SDK from memory: copy the
  example code and adapt names and UI.
- Read [references/flows.md](references/flows.md) for the checkout steps and
  [references/errors.md](references/errors.md) before writing error handling.
- Read [references/swift.md](references/swift.md) for installation, the minimum iOS version, the
  completion-handler API and its async wrappers, the list of SDK methods, the backend contract, the
  universal link and URL scheme setup, and the Swift wrapper that an Objective-C app needs.
- The examples in `examples/` are complete Swift files, one per topic. They are compiled against the SDK
  sources on every SDK build. They are not part of the package: copy the ones you need into your own target,
  at least `AsyncApi.swift` (see [references/swift.md](references/swift.md)).
- For classes and fields not shown here, read the SDK's [README](../../README.md) or the SDK's sources
  (`OnlinePaymentsKit/`). For API fields, see the
  [Client API reference](https://docs.direct.worldline-solutions.com/en/api-reference).

## Mandatory rules

Follow all of these in every integration:

1. Never put the API key or API secret in the app. Create the SDK only with the session data your
   backend returns: `clientSessionId`, `customerId`, `clientApiUrl` and `assetUrl`.
2. Use new session data for every checkout. Do not reuse or cache session data across customers or
   payments. When a call fails with a `ResponseError` with HTTP status 404, the card, payment method
   or currency conversion offer is not available: do not restart; tell the customer, or continue
   without the offer. After any other `ResponseError`, get new session data and create a new
   `OnlinePaymentsSdk`. The SDK has no close method: drop every reference to the old instance. Keep
   a strong reference to the instance until the completion handlers of its calls have run; if it is
   released while a request is running, they never run.
3. Card data only leaves the device through `sdk.encryptPaymentRequest` (or `sdk.encryptTokenRequest`
   for tokenization). Never send raw card data to your backend, never log it and never store it (no
   `UserDefaults`, Keychain, files, Core Data, `@AppStorage`, `@SceneStorage`, state restoration or
   pasteboard). Do not call `sdk.publicKey` to encrypt data yourself. The surcharge and currency
   conversion requests are not encrypted: pass at most the first 8 digits of the card number to them.
4. Build the payment form from the fields returned by `sdk.paymentProduct(withId:...)`: labels, masks,
   placeholders, obfuscation and validation rules. Do not hard-code fields or validation rules for a
   payment product.
5. Validate the `PaymentRequest` with `paymentRequest.validate()` before encrypting it, and show the
   errors to the customer next to their fields.
6. The amount, currency and country in the `PaymentContext` must be the real values of the order
   being paid.
7. The app never decides the payment outcome. After sending the encrypted data, show the result your
   backend returns. When the backend returns a redirect URL, open that URL exactly as received; do
   not build or change it. When the customer comes back to the app, ask your backend for the status:
   store the order id before opening the URL, and handle the return link at the root of the app (the
   scene delegate, the app delegate or SwiftUI `onOpenURL`), also when the link starts the app (see
   `examples/RedirectHandling.swift`). Never read the outcome from the link. This applies to every
   payment that can return a redirect URL, including Apple Pay.
8. Leave `SdkConfiguration.loggingEnabled` at `false` (the default) and never set it to `true` in a
   release build: it prints the SDK's HTTP requests and responses, including the session id header,
   to the console. Do not log form values, `PaymentRequest` values or SDK request bodies with `print`,
   `os_log`, `Logger`, `NSLog`, crash reporting or analytics. Log only error ids and codes.

## Checkout steps

1. Get new session data from your backend and create
   `OnlinePaymentsSdk(sessionData:configuration:)`.
2. Build the `PaymentContext` from the order.
3. `sdk.basicPaymentProducts(forContext:...)`: show payment products and stored cards.
4. `sdk.paymentProduct(withId:...)`: render the form from its fields.
5. While the customer types: `sdk.iinDetails(...)` for the card brand (one call at a time),
   `setValue` and `maskedValue` for formatting, `validate()` per field.
6. Optional: `sdk.surchargeCalculation(...)` or `sdk.currencyConversionQuote(...)`. A currency
   conversion offer must not have a preselected option; the customer actively chooses.
7. `paymentRequest.validate()`, then `sdk.encryptPaymentRequest(...)`.
8. Send `encryptedCustomerInput` and `encodedClientMetaInfo` to your backend, plus `dccSessionId`
   and `acceptedByUser` when a currency conversion offer was shown.
9. Handle the backend's response: open the redirect URL or show the result. When the customer
   returns through the link (also when it starts the app), ask your backend for the status.

Card tokenization without a payment, and what the SDK does for Apple Pay, are described in
[references/flows.md](references/flows.md).
