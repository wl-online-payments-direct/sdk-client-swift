# Swift SDK reference

## Installation

**Swift Package Manager** (recommended). In Xcode choose File > Add Package Dependencies, enter
`https://github.com/wl-online-payments-direct/sdk-client-swift` and pick the SDK version, or add the
dependency to your `Package.swift`, where `x.y.z` is the SDK version:

```swift
dependencies: [
    .package(url: "https://github.com/wl-online-payments-direct/sdk-client-swift", from: "x.y.z")
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [.product(name: "OnlinePaymentsKit", package: "sdk-client-swift")]
    )
]
```

`x.y.z` is a placeholder. Use the SDK version the project already uses, or the version in the link this skill
was read from. If neither is known, ask the user which version to use (the releases page lists them). Never
guess a version number.

The package pulls in its own dependencies (Alamofire and CryptoSwift); you add nothing else. It also lists
OHHTTPStubs, which only its tests use: SwiftPM fetches it but it is not linked into your app. The package
checkout contains this skill in `skills/onlinepayments-sdk-client-swift/`.

**XCFramework.** Download `OnlinePaymentsKit.xcframework` from the
[releases page](https://github.com/wl-online-payments-direct/sdk-client-swift/releases) and drag it into
"Frameworks, Libraries, and Embedded Content" of the target as "Embed & Sign". Alamofire and CryptoSwift are
linked statically into it: add nothing else.

**Carthage.** Add `github "wl-online-payments-direct/sdk-client-swift"` to your `Cartfile`, run
`carthage update --use-xcframeworks` and embed the XCFramework from `Carthage/Build` as above.

**CocoaPods is deprecated.** New versions are no longer released there: do not use it for a new integration.

Requirements:

- iOS 15.6 or newer (the README, the podspec and the Xcode project say 15.6; `Package.swift` declares iOS 15).
- To build the package from source (Swift Package Manager) you need a Swift 6.1 or newer compiler (Xcode 16.3
  or newer), because the SDK source uses trailing commas in parameter lists. The XCFramework is built for
  library distribution, so it also works with newer Xcode versions; the README names Swift 5.3 as its minimum.
- The `swift-tools-version` of your own `Package.swift` can stay low (5.9 is enough): the Swift 6.1 requirement is
  about the compiler that builds the SDK source, not about your manifest.
- The examples use only system frameworks: Foundation, UIKit, SwiftUI and `os`, and PassKit for Apple Pay. No
  extra dependency, capability or permission is needed for the SDK itself. A universal link needs the
  Associated Domains capability, and Apple Pay needs the Apple Pay capability (see below).

## Imports

The SDK is one module: `import OnlinePaymentsKit`. All classes are in it: `OnlinePaymentsSdk`, `SessionData`,
`SdkConfiguration`, `PaymentContext`, `AmountOfMoney`, `BasicPaymentProducts`, `BasicPaymentProduct`,
`PaymentProduct`, `PaymentProductField`, `AccountOnFile`, `PaymentRequest`, `PaymentRequestField`,
`CreditCardTokenRequest`, `EncryptedRequest`, `ValidationResult`, `ValidationErrorMessage`,
`IINDetailsResponse`, `IINStatus`, `SurchargeCalculationResponse`, `CurrencyConversionResponse`,
`StringFormatter` and the errors (see [errors.md](errors.md)).

## The completion-handler API and the async wrappers

Every SDK method that calls the Client API takes a `success` and a `failure` closure and returns nothing:

- Exactly one of the two closures runs, once. The closures of network requests run on the main queue.
- A call that needs no request (a cached result, `iinDetails` with fewer than 6 digits, a payment product the
  SDK does not support) runs its closure synchronously on the calling thread, before the method returns.
- If the `OnlinePaymentsSdk` instance is released while a request is running, neither closure runs. Keep the
  instance until the checkout ends. The closures keep running when your screen is closed: capture the screen
  weakly, or deliver the result to a view model.
- The SDK has no `async` API. The examples wrap each method once, with `withCheckedThrowingContinuation`, and
  use the wrappers everywhere. The wrappers are safe because a closure runs exactly once. They need iOS 13 or
  newer, so they work for every supported iOS version.

The files in `examples/` are not part of the package. Copy the ones you need into your own target: at least
`AsyncApi.swift` (the wrappers that the other examples call). `MerchantBackend.swift` and `UiPlaceholders.swift` hold
placeholders that you replace with your own backend and UI code.

The SDK caches payment products, IIN details, surcharge and currency conversion results and the public key for
the lifetime of the `OnlinePaymentsSdk` instance, so create one instance per checkout.

<!-- region: async-wrappers -->
```swift
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
```

## SDK methods

`OnlinePaymentsSdk(sessionData:configuration:)` creates the SDK and throws a `ConfigurationError` for an empty
session value or an invalid `clientApiUrl`. `configuration` is optional: `SdkConfiguration(appIdentifier:
loggingEnabled:)`. `appIdentifier` is your app's name and version, sent in the client meta information (`nil`
is sent as `UNKNOWN`); `loggingEnabled` defaults to `false` and must stay `false` in a release build. The SDK
adds `/client/` to `clientApiUrl` when it is missing.

| Method | Client API operation | Result closure gets |
|---|---|---|
| `basicPaymentProducts(forContext:success:failure:)` | Get payment products | `BasicPaymentProducts` (`paymentProducts`, `accountsOnFile`) |
| `paymentProduct(withId:paymentContext:success:failure:)` | Get payment product | `PaymentProduct` |
| `paymentProductNetworks(forProductId:paymentContext:success:failure:)` | Get payment product networks | `PaymentProductNetworks` |
| `iinDetails(forPartialCardNumber:paymentContext:success:failure:)` | Get IIN details | `IINDetailsResponse` |
| `surchargeCalculation(amountOfMoney:partialCardNumber:paymentProductId:success:failure:)` | Surcharge calculation | `SurchargeCalculationResponse` |
| `surchargeCalculation(amountOfMoney:token:success:failure:)` | Surcharge calculation for a stored card | `SurchargeCalculationResponse` |
| `currencyConversionQuote(amountOfMoney:partialCardNumber:paymentProductId:success:failure:)` | Currency conversion quote | `CurrencyConversionResponse` |
| `currencyConversionQuote(amountOfMoney:token:success:failure:)` | Currency conversion quote for a stored card | `CurrencyConversionResponse` |
| `encryptPaymentRequest(_:success:failure:)` | Gets the public key, validates, then encrypts on the device | `EncryptedRequest` |
| `encryptTokenRequest(_:success:failure:)` | Gets the public key, then encrypts on the device | `EncryptedRequest` |
| `publicKey(success:failure:)` | Get public key | Used internally by the encrypt methods; do not use it to encrypt yourself |

For a stored card, `token` is the account on file's `id`. For a card being entered, pass the first 8 digits as
`partialCardNumber`: the SDK sends exactly what you pass in these two requests, and they are not encrypted.
`iinDetails` uses at most the first 8 digits. `paymentProductId` is an `NSNumber?`.

`encodedClientMetaInfo` contains device information and the `appIdentifier`. The SDK collects it; you only
forward it.

## Domain objects

- `BasicPaymentProducts`: `paymentProducts`, `accountsOnFile`, `paymentProduct(withId:)`.
- `BasicPaymentProduct`: `id` (`Int?`; `idValue` is the same id as an `NSNumber?`, for Objective-C and for
  `CreditCardTokenRequest.paymentProductId`: use `id` everywhere else), `label`, `logo` (a URL or a partial path), `getLogoImage()`,
  `displayOrder`, `allowsTokenization`, `allowsRecurring`, `usesRedirectionTo3rdParty`, `accountsOnFile`,
  `accountOnFile(withIdentifier:)`, `paymentProduct302SpecificData`, `paymentProduct320SpecificData`.
- `PaymentProduct`: everything above plus `fields` (sorted by display order), `field(id:)` (`nil` when the
  product has no such field) and `requiredFields`.
- `PaymentProductField`: `id`, `type`, `label`, `placeholder`, `isRequired`, `shouldObfuscate`, `displayHints`
  (`mask`, `preferredInputType`, `displayOrder`, `formElement`, ...), `applyMask(value:)`, `removeMask(value:)`,
  `validate(value:)` (returns `[ValidationErrorMessage]`).
- `PaymentRequest(paymentProduct:accountOnFile:tokenize:)`: `field(id:)`, `setValue(id:value:)`,
  `value(id:)`, `values()`, `validate()` (returns `ValidationResult` with `isValid` and `errors`),
  `accountOnFile` (read-only: change it with `setAccountOnFile(_:)`) and `tokenize`.
- `PaymentRequestField`: `setValue(value:)` (throws; removes the mask), `value`, `maskedValue`, `clearValue()`,
  `validate()` (does not throw; the `try` in the examples belongs to `field(id:)`).
- `AccountOnFile`: `id`, `paymentProductId`, `label`, `getValue(id:)`, `isWritable(id:)`.
- `ValidationErrorMessage`: `errorMessage` (English text), `paymentProductFieldId`, `type` (`RequiredField`, or
  the name of the rule, for example `LUHN`). To show your own translated texts, map `type` to your texts.
- `IINDetailsResponse`: `status`, `paymentProductId` (`Int?`), `coBrands`, `cardType`, `countryCode`.
- `CurrencyConversionResponse` and `Surcharge`: read the optional parts through the `...OrNil` properties (see
  [flows.md](flows.md#7-surcharge-and-currency-conversion-optional)).

## Your backend

The examples call your own backend through the functions in `examples/MerchantBackend.swift`. The URL, paths
and response shapes are placeholders; the SDK does not call them. The same file also has `submitEncryptedToken`
(tokenization).

Your backend:

- creates the client session with Create Session and returns `clientSessionId`, `customerId`, `clientApiUrl`
  and `assetUrl`. To show stored cards, it passes the customer's tokens to Create Session.
- creates the payment with Create Payment, passing `encryptedCustomerInput` and `encodedClientMetaInfo`, the
  order's amount, and `returnUrl` (your app's link) for 3-D Secure. With a currency conversion choice it sets
  `cardPaymentMethodSpecificInput.currencyConversion` to `{ dccSessionId, acceptedByUser }`. With surcharging it
  sets `order.surchargeSpecificInput.mode` to `on-behalf-of`.
- returns the redirect URL from the Create Payment response when there is one, and the status.
- returns the current payment status when the app asks after the customer came back.

<!-- region: merchant-backend -->
```swift
// The URL, paths and JSON shapes are placeholders for your own backend; the SDK never calls them.
private let backendUrl = "https://shop.example.com"

/// The payment status as your backend reports it.
enum PaymentStatus: String, Decodable {
    case success = "SUCCESS"
    case pending = "PENDING"
    case failed = "FAILED"
}

/// What your backend returns after it created the payment, or when the app asks for the status.
struct MerchantPaymentResponse: Decodable {
    let status: PaymentStatus
    /// Set when the customer must be redirected, for example for 3-D Secure.
    let redirectUrl: String?
}

/// The customer's currency conversion choice. Your backend passes both fields to Create Payment in
/// cardPaymentMethodSpecificInput.currencyConversion. Both are mandatory once a quote was shown.
struct CurrencyConversionChoice {
    let dccSessionId: String
    /// true: pay in the card's currency; false: pay in your currency.
    let acceptedByUser: Bool
}

enum MerchantBackendError: Error {
    case invalidUrl
    case httpStatus(Int)
}

private struct SessionResponse: Decodable {
    let clientSessionId: String
    let customerId: String
    let clientApiUrl: String
    let assetUrl: String
}

private struct TokenResponse: Decodable {
    let token: String
}

// Never log the body you send: it holds the encrypted customer input.
private func postJson(path: String, body: [String: Any] = [:]) async throws -> Data {
    guard let url = URL(string: backendUrl + path) else {
        throw MerchantBackendError.invalidUrl
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (data, response) = try await URLSession.shared.data(for: request)
    if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
        throw MerchantBackendError.httpStatus(httpResponse.statusCode)
    }

    return data
}

/// Your backend creates a new client session for this checkout (Create Session) and returns its data.
func fetchSessionData() async throws -> SessionData {
    let data = try await postJson(path: "/api/checkout/session")
    let session = try JSONDecoder().decode(SessionResponse.self, from: data)

    return SessionData(
        clientSessionId: session.clientSessionId,
        customerId: session.customerId,
        clientApiUrl: session.clientApiUrl,
        assetUrl: session.assetUrl
    )
}

/// Your backend creates the payment (Create Payment) with the encrypted customer input.
func submitEncryptedPayment(
    orderId: String,
    encryptedRequest: EncryptedRequest,
    currencyConversion: CurrencyConversionChoice? = nil // only when a currency conversion offer was shown
) async throws -> MerchantPaymentResponse {
    var body: [String: Any] = [
        "orderId": orderId,
        "encryptedCustomerInput": encryptedRequest.encryptedCustomerInput,
        "encodedClientMetaInfo": encryptedRequest.encodedClientMetaInfo
    ]
    if let currencyConversion = currencyConversion {
        let choice: [String: Any] = [
            "dccSessionId": currencyConversion.dccSessionId,
            "acceptedByUser": currencyConversion.acceptedByUser
        ]
        body["currencyConversion"] = choice
    }

    let data = try await postJson(path: "/api/checkout/payment", body: body)
    return try JSONDecoder().decode(MerchantPaymentResponse.self, from: data)
}

/// Your backend reads the payment status, for example after the customer returned from 3-D Secure.
func fetchPaymentStatus(orderId: String) async throws -> MerchantPaymentResponse {
    let data = try await postJson(path: "/api/checkout/status", body: ["orderId": orderId])
    return try JSONDecoder().decode(MerchantPaymentResponse.self, from: data)
}

/// Your backend creates a payment token (Create Token) from the encrypted card data. Returns the token id.
func submitEncryptedToken(_ encryptedRequest: EncryptedRequest) async throws -> String {
    let body: [String: Any] = [
        "encryptedCustomerInput": encryptedRequest.encryptedCustomerInput,
        "encodedClientMetaInfo": encryptedRequest.encodedClientMetaInfo
    ]
    let data = try await postJson(path: "/api/checkout/token", body: body)
    return try JSONDecoder().decode(TokenResponse.self, from: data).token
}
```

## Returning from 3-D Secure

The customer returns to the app through the `returnUrl` your backend sent in Create Payment.

- Choose a return URL that only your app handles. A **universal link** (an `https` link on your domain, which
  the system opens in your app) is the safest. A **custom URL scheme** such as `myshop://payment-return` also
  works, but any other app can register the same scheme. With either, never read the payment outcome from the
  link: ask your backend for the status.
- Test the return on a device. An automatic redirect to a universal link does not always open the app: let your
  return page show a button that opens the link, or use a custom URL scheme.
- Open the redirect URL with `UIApplication.shared.open` (leaves the app for Safari), or with an
  `SFSafariViewController` or an `ASWebAuthenticationSession` (a sheet inside the app; with a callback URL
  scheme the sheet closes by itself when the page redirects to that scheme). Whichever you use, open the URL
  exactly as received and save the order id first.
- Handle the link at the root of the app (see [flows.md](flows.md#10-handle-the-result)), also when it starts the
  app. `returnUrlPrefix` in `examples/RedirectHandling.swift` must match the return URL.

For a universal link, add the Associated Domains capability to the app target (this adds an entry to the
`.entitlements` file) and host an `apple-app-site-association` file on your domain:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:shop.example.com</string>
</array>
```

```json
{
    "applinks": {
        "details": [
            { "appIDs": ["TEAMID.com.example.shop"], "components": [{ "/": "/payment-return*" }] }
        ]
    }
}
```

The JSON file is served at `https://shop.example.com/.well-known/apple-app-site-association` without a file
extension, over HTTPS. For a custom URL scheme, add it to the target's `Info.plist` (URL Types) and change
`returnUrlPrefix` to `myshop://payment-return`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myshop</string>
        </array>
    </dict>
</array>
```

## Objective-C

Objective-C code cannot use the SDK directly:

- It cannot create the SDK: the initializer and the properties of `SessionData` (`OPSessionData`) and of
  `SdkConfiguration` are not visible to Objective-C.
- It cannot read an error: `message`, `code` and `metadata` of `SdkError` and `httpStatusCode` of `ResponseError`
  are not visible, so the error handling in [errors.md](errors.md) cannot be written in Objective-C.

For an Objective-C app, write the code that uses the SDK in Swift and call it through a wrapper:

- Add a Swift file to the app target. Xcode generates the header `<ProductModuleName>-Swift.h`; import it in the
  Objective-C files that use the wrapper.
- In that file, copy and adapt the examples as for a Swift app: create the SDK as in `Initialisation.swift`, and
  handle errors with `classifySdkError` and `fieldErrors(from:)` from `ErrorHandling.swift`.
- Give Objective-C only what the screens need: a class that inherits from `NSObject`, marked `@objc`, with `@objc`
  methods that take and return Objective-C types (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`, blocks, `@objc`
  classes such as the SDK's `OP` classes, and `@objc` enums with an `Int` raw value). Return the result of
  `classifySdkError` as such an enum, not the `SdkError`, whose fields Objective-C cannot read.
- The async wrappers in `AsyncApi.swift` are Swift only: give the `@objc` methods completion blocks.
