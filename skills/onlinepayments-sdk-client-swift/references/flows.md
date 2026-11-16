# Checkout flows

Every code block below is copied from a file in `../examples/`. The examples call your backend through
the functions in `examples/MerchantBackend.swift`; see [swift.md](swift.md#your-backend) for that
contract. They call the SDK through the `async` wrappers in `examples/AsyncApi.swift` (see
[swift.md](swift.md#the-completion-handler-api-and-the-async-wrappers)).

The examples are plain functions and classes, not screens. Call them from a `Task` that follows your
screen's lifecycle, for example from a view model. Keep the `OnlinePaymentsSdk` instance in the view
model or another holder that survives the screen, but not longer than the checkout.

## 1. Create the SDK

Your backend creates a client session with Create Session and returns its data. Do this for every
checkout, and keep the `OnlinePaymentsSdk` instance for the whole checkout.

<!-- region: initialise-sdk -->
```swift
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
```

The SDK has no close or dispose method. When the checkout ends (paid, cancelled or restarted with new
session data), drop every reference to the instance.

## 2. Build the payment context

The payment context is passed to most SDK calls. The payment products, surcharge and currency
conversion depend on it, so it must match the order.

<!-- region: payment-context -->
```swift
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
```

## 3. List payment products and stored cards

`basicPaymentProducts` returns the payment products available for this context and the customer's
accounts on file (stored cards). Accounts on file are only returned when your backend passed the
customer's tokens to Create Session. The SDK already removes the products it cannot process (Maestro
117 and three gift cards) and Apple Pay (302) when the device cannot pay with it. It keeps Apple Pay
when it can, so remove it when your app does not implement Apple Pay (see [Apple Pay](#apple-pay)). The
SDK does not sort the products.

<!-- region: list-payment-products -->
```swift
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
```

A product's `logo` can be a partial path. The SDK downloads the logo itself only when `logo` is a full
URL (then `getLogoImage()` returns the image). Build the full URL with the session's `assetUrl` when
it is a path.

<!-- region: logo-url -->
```swift
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
```

## 4. Render the payment form

When the customer selects a product or a stored card, get the full product. It contains the fields to
render. For a stored card, pass the account on file's `paymentProductId`.

<!-- region: get-payment-product -->
```swift
/// Loads the full product with its fields. For a stored card, pass the account on file's paymentProductId.
func loadPaymentProduct(
    sdk: OnlinePaymentsSdk,
    productId: Int,
    context: PaymentContext
) async throws -> PaymentProduct {
    try await sdk.fetchPaymentProduct(withId: productId, context: context)
}
```

Describe the form from the product's fields, then render one input per field. Fields of a stored card
that are not editable are shown with their stored value and cannot be changed. Show a field with
`obfuscate` set as a secure text field.

<!-- region: describe-form-fields -->
```swift
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
```

## 5. Detect the card brand

When at least 6 digits have been entered, get the IIN details to find the payment product for the card.
Use the returned `paymentProductId` to show the brand logo and, if it differs from the selected
product, load that product with `paymentProduct(withId:...)` and create a new `PaymentRequest` for it.
A co-branded card has entries in `coBrands`; each has a `paymentProductId`.

What `iinDetails` returns and fails with:

- Fewer than 6 digits (spaces are ignored): it makes no request and calls `success` with the status
  `.notEnoughDigits`.
- A card number that matches no payment product of your account (the API answers HTTP 404): it
  calls `success` with the status `.unknown`.
- A card that is known but not accepted for this payment: `.existingButNotAllowed`. An accepted card:
  `.supported`. All four statuses can be returned.
- Every other API error, for example an expired session, calls `failure` with a `ResponseError`.
  Unlike the 404, it is not turned into `.unknown`.
- A second lookup started while one is running is **not** rejected: both requests are sent and the
  answers can arrive in any order. Run one lookup at a time and ignore answers for input that is no
  longer current (`CardDetector` below does this).
- Results are cached per SDK instance, and a cached answer is delivered synchronously, on the calling
  thread.

<!-- region: iin-details -->
```swift
/// What the card number entered so far tells you.
enum CardLookup {
    case product(id: Int, coBrandIds: [Int]) // the card is accepted for this payment
    case notAccepted // a known card that is not allowed for this payment
    case unknown // no payment product of your account matches the card: do not block the form
    case needMoreDigits // fewer than 6 digits
}

func lookUpCard(sdk: OnlinePaymentsSdk, context: PaymentContext, enteredNumber: String) async throws -> CardLookup {
    // Fewer than 6 digits (spaces are ignored): no request is made and the status is .notEnoughDigits.
    // A card that matches no payment product (the API answers HTTP 404): the status is .unknown.
    // Neither case is an error. Every other API error, for example an expired session, is thrown as a
    // ResponseError: restart the checkout (see ErrorHandling.swift).
    let response = try await sdk.fetchIinDetails(partialCardNumber: enteredNumber, context: context)

    if response.status == .notEnoughDigits {
        return .needMoreDigits
    }
    if response.status == .existingButNotAllowed {
        return .notAccepted
    }
    guard response.status == .supported, let productId = response.paymentProductId else {
        return .unknown
    }

    // A co-branded card has entries in coBrands: let the customer choose one of the allowed brands.
    let coBrandIds = response.coBrands.filter { $0.allowedInContext }.map { $0.paymentProductId }
    return .product(id: productId, coBrandIds: coBrandIds)
}
```

<!-- region: card-detector -->
```swift
/// Runs one IIN lookup at a time. The SDK does not reject a second lookup while one is running, and the answers
/// can arrive in any order, so only the lookup for the latest input may update the screen.
@MainActor
final class CardDetector {
    private let sdk: OnlinePaymentsSdk
    private let context: PaymentContext
    private let onResult: (Result<CardLookup, Error>) -> Void
    private var latestInput = ""
    private var isRunning = false

    init(sdk: OnlinePaymentsSdk, context: PaymentContext, onResult: @escaping (Result<CardLookup, Error>) -> Void) {
        self.sdk = sdk
        self.context = context
        self.onResult = onResult
    }

    /// Call whenever the card number field changes.
    func cardNumberChanged(_ cardNumber: String) {
        latestInput = cardNumber
        guard !isRunning else {
            return
        }

        isRunning = true
        Task { await runLookups() }
    }

    private func runLookups() async {
        defer { isRunning = false }

        while true {
            let lookedUp = latestInput
            do {
                let lookup = try await lookUpCard(sdk: sdk, context: context, enteredNumber: lookedUp)
                if lookedUp == latestInput {
                    onResult(.success(lookup))
                }
            } catch {
                if lookedUp == latestInput {
                    onResult(.failure(error))
                }
            }

            // The customer typed more while the lookup ran: look up the latest input.
            if lookedUp == latestInput {
                return
            }
        }
    }
}
```

## 6. Format and validate input

Create the `PaymentRequest` once the product is loaded.

<!-- region: create-payment-request -->
```swift
/// Create the request once the product is loaded. For a stored card pass its account on file. With saveCard
/// the platform stores the card as an account on file when the payment succeeds.
func makePaymentRequest(
    product: PaymentProduct,
    accountOnFile: AccountOnFile?,
    saveCard: Bool
) -> PaymentRequest {
    PaymentRequest(paymentProduct: product, accountOnFile: accountOnFile, tokenize: saveCard)
}
```

Format each editable field while the customer types. `setValue` removes the mask, stores the value in
the `PaymentRequest` and `maskedValue` returns the text to show.

<!-- region: mask-input -->
```swift
/// Call on every change of a text field. It stores what the customer typed (the SDK removes the mask itself)
/// and returns the text to show in the field. It throws an InvalidArgumentError for a field id the product does
/// not have, or for a field that is read-only for the stored card.
func updateField(_ request: PaymentRequest, fieldId: String, typedText: String) throws -> String {
    let field = try request.field(id: fieldId)
    try field.setValue(value: typedText)

    return field.maskedValue ?? ""
}
```

<!-- region: validate-field -->
```swift
/// Validates one field, for example when the customer leaves it. An empty result means the value is valid.
func validateField(_ request: PaymentRequest, fieldId: String) throws -> [ValidationErrorMessage] {
    try request.field(id: fieldId).validate().errors
}
```

Before encrypting, validate the whole request (`validate()` is marked `throws`, so call it with `try`).
A validation error has an English `errorMessage`, the
`paymentProductFieldId` and a `type`: `RequiredField`, or the name of the rule that failed (for example
`LUHN`, `EXPIRATIONDATE`, `LENGTH`, `REGULAREXPRESSION`, `EMAILADDRESS`, `FIXEDLIST`, `IBAN`, `RANGE` or
`TERMSANDCONDITIONS`).

<!-- region: validate-payment-request -->
```swift
/// Validates the whole request before encrypting it. Returns the errors per field id: show each one next to its
/// field. An empty result means the request can be encrypted.
func validateRequest(_ request: PaymentRequest) throws -> [String: [ValidationErrorMessage]] {
    let result = try request.validate()

    return Dictionary(grouping: result.errors) { $0.paymentProductFieldId ?? "" }
}
```

To show your own translated texts, map the error's `type` to your texts.

<!-- region: validation-texts -->
```swift
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
```

The SDK also offers `StringFormatter`, which applies and removes a mask for values that are not stored
in a `PaymentRequest`.

<!-- region: string-formatter -->
```swift
/// StringFormatter applies and removes a field's mask. PaymentRequestField does this for you (see mask-input);
/// use StringFormatter for values that are not stored in a PaymentRequest.
func formatWithMask(_ unmaskedValue: String, mask: String) -> String {
    StringFormatter().formatString(string: unmaskedValue, mask: mask)
}

func removeMask(from maskedValue: String, mask: String) -> String {
    StringFormatter().unformatString(string: maskedValue, mask: mask)
}
```

## 7. Surcharge and currency conversion (optional)

Only when your merchant account has surcharging or dynamic currency conversion enabled. Call these once
the card product is known, and show the result before the customer pays.

These requests are not encrypted, and the SDK sends exactly what you pass in. It does **not** shorten
the card number. Pass the first 8 digits (at least 6) of a card being entered together with its payment
product id, never the full number. For a stored card pass the account on file's id.

<!-- region: card-reference -->
```swift
/// What identifies the card for a surcharge or currency conversion request. These requests are not encrypted:
/// for a card being entered send only its first 8 digits (at least 6) with the payment product id, never the full
/// number. For a stored card send the account on file's id.
enum CardReference {
    case entered(cardNumber: String, productId: Int)
    case stored(accountOnFileId: String)
}

private func firstDigits(of cardNumber: String) -> String {
    String(cardNumber.filter { $0.isNumber }.prefix(8))
}
```

### Surcharge

The payment context keeps the net amount (without surcharge); the platform adds the surcharge when
your backend creates the payment with `order.surchargeSpecificInput.mode` set to `on-behalf-of`. Show
the surcharge and the total before the customer pays.

The API leaves the amounts out when no surcharge applies. The SDK still decodes the response, so the
call succeeds, but `netAmount`, `surchargeAmount` and `totalAmount` then hold a placeholder (amount 0,
currency code `UNKNOWN`). Read `result` first, and read the amounts through `netAmountOrNil`,
`surchargeAmountOrNil` and `totalAmountOrNil`, which are `nil` when the API sent none.

<!-- region: surcharge-calculation -->
```swift
struct SurchargeOffer {
    let surchargeAmount: AmountOfMoney
    let totalAmount: AmountOfMoney
}

/// Only when your merchant account has surcharging enabled. The payment context keeps the net amount; the platform
/// adds the surcharge when your backend creates the payment with order.surchargeSpecificInput.mode set to
/// "on-behalf-of". Returns nil when no surcharge applies.
func loadSurcharge(
    sdk: OnlinePaymentsSdk,
    amount: AmountOfMoney,
    card: CardReference
) async throws -> SurchargeOffer? {
    let response: SurchargeCalculationResponse
    switch card {
    case let .entered(cardNumber, productId):
        response = try await sdk.fetchSurcharge(
            amount: amount,
            partialCardNumber: firstDigits(of: cardNumber),
            paymentProductId: productId
        )
    case let .stored(accountOnFileId):
        response = try await sdk.fetchSurcharge(amount: amount, token: accountOnFileId)
    }

    // The API leaves the amounts out when no surcharge applies. Read the result first, and the amounts through
    // the ...OrNil properties, which are nil when the API sent nothing.
    guard let surcharge = response.surcharges.first,
        surcharge.result == .ok,
        let surchargeAmount = surcharge.surchargeAmountOrNil,
        let totalAmount = surcharge.totalAmountOrNil
    else {
        return nil
    }

    return SurchargeOffer(surchargeAmount: surchargeAmount, totalAmount: totalAmount)
}
```

### Currency conversion

Dynamic currency conversion (eDCC, Visa and Mastercard only) lets the customer pay in their card's
currency. The card schemes' rules apply to how you show the offer:

- Show both amounts as two equal options: same size, colour and font. Include your currency, the card's
  currency, the exchange rate, the mark-up (`markUpRate` is a percentage: 3.12 means 3.12 %) and
  `proposal.disclaimerDisplay`.
- Preselect neither option. Do not use a yes/no or accept/decline question, a switch or a toggle: the
  customer must actively choose one amount.
- If the customer chooses your currency, continue in your currency and do not offer the conversion
  again in this checkout.

When the result is not `.allowed`, the API sends no `proposal` and an empty `dccSessionId`. The call
still succeeds. `proposal` and `dccSessionId` then hold placeholders (a proposal with zero amounts and
the currency code `UNKNOWN`, and an empty string). Check `result.result` first, and read the offer
through `proposalOrNil` and `dccSessionIdOrNil`, which are `nil` when the API sent none.

<!-- region: currency-conversion -->
```swift
struct CurrencyOffer {
    let dccSessionId: String
    let merchantAmount: AmountOfMoney // in your currency
    let cardAmount: AmountOfMoney // in the card's currency
    let exchangeRate: Double
    let markUpPercent: Double // 3.12 means 3.12 %
    let disclaimer: String? // show it next to the two options
}

/// Only when your merchant account has dynamic currency conversion enabled (Visa and Mastercard only). A card that
/// cannot be converted gets no offer: the result is not .allowed, or the call fails with HTTP 404. Returns nil then.
func loadCurrencyOffer(
    sdk: OnlinePaymentsSdk,
    amount: AmountOfMoney,
    card: CardReference
) async throws -> CurrencyOffer? {
    let response: CurrencyConversionResponse
    do {
        switch card {
        case let .entered(cardNumber, productId):
            response = try await sdk.fetchCurrencyConversionQuote(
                amount: amount,
                partialCardNumber: firstDigits(of: cardNumber),
                paymentProductId: productId
            )
        case let .stored(accountOnFileId):
            response = try await sdk.fetchCurrencyConversionQuote(amount: amount, token: accountOnFileId)
        }
    } catch let error as ResponseError where error.httpStatusCode == 404 {
        return nil // the card cannot be converted: no offer
    }

    // When the result is not .allowed the API sends no proposal and an empty dccSessionId. Check the result
    // first, and read both through the ...OrNil properties.
    guard response.result.result == .allowed,
        let proposal = response.proposalOrNil,
        let dccSessionId = response.dccSessionIdOrNil
    else {
        return nil
    }

    return CurrencyOffer(
        dccSessionId: dccSessionId,
        merchantAmount: proposal.baseAmount,
        cardAmount: proposal.targetAmount,
        exchangeRate: proposal.rate.exchangeRate,
        markUpPercent: proposal.rate.markUpRate,
        disclaimer: proposal.disclaimerDisplay
    )
}
```

When the customer has chosen, send the choice with the payment. Your backend passes it to Create
Payment as `cardPaymentMethodSpecificInput.currencyConversion`. Both `dccSessionId` and
`acceptedByUser` are required, also when the customer chose your currency (`acceptedByUser: false`).

<!-- region: currency-conversion-choice -->
```swift
/// Call this when the customer has actively chosen one of the two equal options (no option preselected, no
/// yes/no question). Send the result with the payment: both values are mandatory once a quote was shown, also
/// when the customer keeps your currency (payInCardCurrency false). If the customer declined the offer, do not
/// offer it again in this checkout.
func chooseCurrency(offer: CurrencyOffer, payInCardCurrency: Bool) -> CurrencyConversionChoice {
    CurrencyConversionChoice(dccSessionId: offer.dccSessionId, acceptedByUser: payInCardCurrency)
}
```

When both surcharging and currency conversion apply, calculate the surcharge first and request the
currency conversion quote for the surcharge's `totalAmount` (net amount plus surcharge), as the Client
API reference prescribes. Without a surcharge, request it for the order amount. The payment context
keeps the net amount in both cases.

<!-- region: surcharge-then-currency-conversion -->
```swift
struct CheckoutOffers {
    let surcharge: SurchargeOffer?
    let currency: CurrencyOffer?
}

/// When surcharging and currency conversion both apply, calculate the surcharge first and request the currency
/// conversion quote for the surcharge's total amount (net amount plus surcharge). Without a surcharge, request it
/// for the order amount. The payment context keeps the net amount in both cases.
func loadOffers(sdk: OnlinePaymentsSdk, order: Order, card: CardReference) async throws -> CheckoutOffers {
    let orderAmount = AmountOfMoney(amount: order.amountInCents, currencyCode: order.currencyCode)

    let surcharge = try await loadSurcharge(sdk: sdk, amount: orderAmount, card: card)
    let amountToConvert = surcharge?.totalAmount ?? orderAmount
    let currency = try await loadCurrencyOffer(sdk: sdk, amount: amountToConvert, card: card)

    return CheckoutOffers(surcharge: surcharge, currency: currency)
}
```

## 8. Encrypt and send to your backend

`encryptPaymentRequest` validates the request again and calls `failure` with an `InvalidArgumentError`
if it is not valid. The result has two parts: `encryptedCustomerInput` and `encodedClientMetaInfo`.
Send both to your backend; it passes them to Create Payment.

<!-- region: encrypt-payment-request -->
```swift
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
```

## 9. Session expired or other API errors

When an SDK call fails with a `ResponseError`, the session is no longer usable, unless the HTTP status is
404 (the card, payment method or currency conversion offer is not available: do not restart). Get new
session data, create a new `OnlinePaymentsSdk`, load the payment product again and create a new
`PaymentRequest`. See [errors.md](errors.md). Whether the customer's input is kept after a new session is
your decision; this skill does not prescribe it.

<!-- region: restart-checkout -->
```swift
/// Holds the SDK of the running checkout.
@MainActor
final class CheckoutSession {
    private(set) var sdk: OnlinePaymentsSdk?

    func start() async throws {
        sdk = try await makeSdk()
    }

    /// After a ResponseError other than HTTP 404 the session is no longer usable. Drop the old instance, get new
    /// session data and create a new SDK. Then load the payment product again and create a new PaymentRequest.
    /// Whether the customer's input is kept is your decision.
    func restart() async throws {
        sdk = nil
        sdk = try await makeSdk()
    }
}
```

## 10. Handle the result

Your backend returns what Create Payment returned. When the payment needs a redirect (for example
3-D Secure), the backend returns the redirect URL from that response. The app opens it and records the
order id, so it can ask for the status when the customer comes back. Keep only the order id, never form
values.

<!-- region: pending-payment-store -->
```swift
/// The only thing the app keeps across a restart: the id of the order that waits for its result. Never store
/// card data, form values or an encrypted request.
enum PendingPaymentStore {
    private static let key = "pendingOrderId"

    static var orderId: String? {
        UserDefaults.standard.string(forKey: key)
    }

    static func save(orderId: String) {
        UserDefaults.standard.set(orderId, forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
```

<!-- region: handle-payment-result -->
```swift
/// Shows what your backend returned for Create Payment. The app never decides the outcome itself. When the
/// backend returns a redirect URL (for example for 3-D Secure), save the order id first, then open the URL exactly
/// as received: do not build or change it.
@MainActor
func handlePaymentResponse(
    _ response: MerchantPaymentResponse,
    orderId: String,
    showResult: (PaymentStatus) -> Void
) {
    guard let redirectUrl = response.redirectUrl, let url = URL(string: redirectUrl) else {
        showResult(response.status)
        return
    }

    PendingPaymentStore.save(orderId: orderId)
    UIApplication.shared.open(url)
}
```

`UIApplication.open` leaves the app for Safari. Other ways to open the URL (an
`SFSafariViewController`, or an `ASWebAuthenticationSession`) are possible; with any of them the URL
stays exactly as received and the order id is saved first. See
[swift.md](swift.md#returning-from-3-d-secure) for how the customer comes back.

After the redirect, the customer comes back through your return URL (see
[swift.md](swift.md#returning-from-3-d-secure)). Handle it at the root of the app, not in the checkout
screen. The same code covers both cases: the app is running, and the system stopped the app while the
customer was on the 3-D Secure page, so the link starts it. Act only when a payment waits for its
result, and ask your backend for the status; never read the outcome from the link.

<!-- region: handle-return-link -->
```swift
// The returnUrl that your backend sends in Create Payment: a universal link that only your app handles.
private let returnUrlPrefix = "https://shop.example.com/payment-return"

/// Call it for every link the app receives, at the root of the app (see the three examples below). It acts only
/// when the link is the return URL and a payment waits for its result. It never reads the outcome from the link:
/// it asks your backend for the status. The result is delivered on the main thread. Returns true when it handled
/// the link.
@discardableResult
func handleReturnLink(_ url: URL, onResult: @escaping @MainActor (Result<PaymentStatus, Error>) -> Void) -> Bool {
    guard url.absoluteString.hasPrefix(returnUrlPrefix), let orderId = PendingPaymentStore.orderId else {
        return false
    }

    Task { @MainActor in
        let result: Result<PaymentStatus, Error>
        do {
            let response = try await fetchPaymentStatus(orderId: orderId)
            if response.status != .pending {
                PendingPaymentStore.clear()
            }
            result = .success(response.status)
        } catch {
            // Keep the order id: the customer can try to check the status again.
            result = .failure(error)
        }
        onResult(result)
    }

    return true
}
```

UIKit with scenes (the default for new apps):

<!-- region: return-link-scene-delegate -->
```swift
// UIKit with scenes. Handle the link here, not in the checkout screen, so that it also works when the link
// starts the app (the system stopped the app while the customer was on the 3-D Secure page).
@MainActor
final class ExampleSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // The app was not running and a link started it.
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        for urlContext in connectionOptions.urlContexts {
            handle(urlContext.url)
        }
        for activity in connectionOptions.userActivities where activity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = activity.webpageURL {
                handle(url)
            }
        }
    }

    // The app is running and a custom URL scheme link opens it.
    func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
        for urlContext in urlContexts {
            handle(urlContext.url)
        }
    }

    // The app is running and a universal link opens it.
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
            handle(url)
        }
    }

    private func handle(_ url: URL) {
        handleReturnLink(url) { result in showPaymentResult(result) }
    }
}
```

UIKit without scenes:

<!-- region: return-link-app-delegate -->
```swift
// UIKit without scenes: the app delegate receives the links, also when a link starts the app.
@MainActor
final class ExampleAppDelegate: UIResponder, UIApplicationDelegate {
    // A custom URL scheme link.
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        handleReturnLink(url) { result in showPaymentResult(result) }
    }

    // A universal link.
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else {
            return false
        }

        return handleReturnLink(url) { result in showPaymentResult(result) }
    }
}
```

SwiftUI:

<!-- region: return-link-swiftui -->
```swift
// SwiftUI: onOpenURL receives custom URL scheme links and universal links, also when the link starts the app.
// Add @main to your own App type.
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Checkout") // your root view
                .onOpenURL { url in
                    handleReturnLink(url) { result in showPaymentResult(result) }
                }
        }
    }
}
```

## Tokenization without a payment

To store a card without paying, use `CreditCardTokenRequest`. It applies no validation of its own, so
validate the values with the card product's fields first (a masked expiry date such as `12/26` fails
the rules, so remove the mask: a `PaymentRequest` does this). Load the card product with `iinDetails`
and `paymentProduct(withId:...)` as in a payment. There is no order amount, so create the payment context
with an amount of 1, the smallest unit of the currency (for example 1 cent for EUR). Do not use 0: the
Client API answers an amount of 0 with an error. The token request needs the payment product id,
otherwise the encryption fails with an `EncryptionError`.

<!-- region: tokenization-product -->
```swift
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
```

<!-- region: encrypt-token-request -->
```swift
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
```

## Apple Pay

The SDK has no Apple Pay payment flow: it does not show the payment sheet and it does not handle the
Apple Pay token. It only:

- lists Apple Pay (product 302) in `basicPaymentProducts` when the device can make Apple Pay payments
  (`PKPaymentAuthorizationViewController.canMakePayments()`) and can pay with the card networks that
  the API returns for the payment context (`paymentProductNetworks`). Otherwise it removes the product
  from the list;
- returns the card networks of product 302 as strings in `paymentProduct302SpecificData.networks` of
  the `BasicPaymentProduct`, and as `PKPaymentNetwork` values from `paymentProductNetworks(forProductId:...)`.

Everything else is your code, with PassKit: the `PKPaymentRequest` (merchant identifier, capabilities,
networks, country, currency and the summary items with the real order amount), the payment sheet and
sending the Apple Pay token to your backend, which creates the payment (the Worldline Direct
documentation for Apple Pay describes the merchant identifiers and the backend call). An Apple Pay
payment can also return a redirect URL: handle it exactly as in [10. Handle the result](#10-handle-the-result).
