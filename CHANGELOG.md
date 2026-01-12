# 5.0.0

## Breaking Changes

### API Redesign

The SDK has been completely redesigned to provide a cleaner, more Swift-idiomatic API. The main `Session` class has been renamed to `OnlinePaymentsSdk` and the initialization and method signatures have been updated.

**Old API (Session):**
```swift
let session = Session(
    clientSessionId: "47e9dc332ca24273818be2a46072e006",
    customerId: "9991-0d93d6a0e18443bd871c89ec6d38a873",
    baseURL: "https://clientapi.com",
    assetBaseURL: "https://assets.com",
    appIdentifier: "My Application/v2.0.4",
    loggingEnabled: true
)
```

**New API (OnlinePaymentsSdk):**
```swift
let sessionData = SessionData(
    clientSessionId: "47e9dc332ca24273818be2a46072e006",
    customerId: "9991-0d93d6a0e18443bd871c89ec6d38a873",
    clientApiUrl: "https://clientapi.com",
    assetUrl: "https://assets.com"
)

let configuration = SdkConfiguration(
    appIdentifier: "My Application/v2.0.4"
)

let sdk = try OnlinePaymentsSdk(
    sessionData: sessionData,
    configuration: configuration
)
```

### Method Signature Changes

All SDK methods now only use two callbacks (`success` and `failure`) instead of three (`success`, `failure`, and `apiFailure`). The method names have been kept as similar as possible to the previous version to minimize migration effort.

| Old Method (Session)                                                                                               | New Method (OnlinePaymentsSdk)                                                                |
|--------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| `session.paymentItems(for:groupPaymentProducts:success:failure:apiFailure:)`                                       | `sdk.basicPaymentProducts(forContext:success:failure:)`                                       |
| `session.paymentProduct(withId:context:success:failure:apiFailure:)`                                               | `sdk.paymentProduct(withId:paymentContext:success:failure:)`                                  |
| `session.paymentProductNetworks(forProductId:context:success:failure:apiFailure:)`                                 | `sdk.paymentProductNetworks(forProductId:paymentContext:success:failure:)`                    |
| `session.iinDetails(forPartialCreditCardNumber:context:success:failure:apiFailure:)`                               | `sdk.iinDetails(forPartialCardNumber:paymentContext:success:failure:)`                        |
| `session.prepare(_:success:failure:apiFailure:)`                                                                   | `sdk.encryptPaymentRequest(_:success:failure:)`                                               |
| `session.publicKey(success:failure:apiFailure:)`                                                                   | `sdk.publicKey(success:failure:)`                                                             |
| `session.surchargeCalculation(amountOfMoney:partialCreditCardNumber:paymentProductId:success:failure:apiFailure:)` | `sdk.surchargeCalculation(amountOfMoney:partialCardNumber:paymentProductId:success:failure:)` |
| `session.surchargeCalculation(amountOfMoney:token:success:failure:apiFailure:)`                                    | `sdk.surchargeCalculation(amountOfMoney:token:success:failure:)`                              |

**Example migration:**

Old API:
```swift
session.paymentItems(
    for: paymentContext,
    groupPaymentProducts: false,
    success: { paymentItems in
        // Display payment items
    },
    failure: { error in
        // Handle SDK error
    },
    apiFailure: { errorResponse in
        // Handle API error
    }
)
```

New API:
```swift
sdk.basicPaymentProducts(
    forContext: paymentContext,
    success: { basicPaymentProducts in
        // Display payment products
    },
    failure: { error in
        // Handle all errors (SDK and API errors are now unified)
    }
)
```

### Type Changes

Payment product identifiers have been changed from `String` to `Int?` to align with the API specification:

* `BasicPaymentProduct.identifier` (String) → `BasicPaymentProduct.id` (Int?)
  * For Objective-C compatibility, use the `idValue: NSNumber?` property
* `PaymentProduct.identifier` (String) → `PaymentProduct.id` (Int?)
  * For Objective-C compatibility, use the `idValue: NSNumber?` property
* `IINDetailsResponse.paymentProductId` changed from `String?` to `Int?`
  * For Objective-C compatibility, use the `paymentProductIdValue: NSNumber?` property

Additional type changes

* `EncryptedRequest.encryptedFields` is changed to `EncryptedRequest.encryptedCustomerInput` to be aligned with the property
  expected on the server side.

### PaymentRequest API Changes

The method for setting field values has been updated:

Old API:
```swift
paymentRequest.setValue(forField: "cardNumber", value: "4242424242424242")
```

New API:
```swift
try paymentRequest.field(id: "cardNumber").setValue(value: "4242424242424242")
```

### Removed Parameters

* The `groupPaymentProducts` parameter has been removed from the payment products retrieval method. Payment products are no longer grouped.
* The `apiFailure` callback has been removed from all methods. API errors are now reported through the unified `failure` callback.

## Changed

* Comprehensive documentation is added to all public methods following Swift API Design Guidelines.
* Internal architecture refactored with a clean separation of concerns (Domain, Infrastructure, Services layers).
* Encryption logic optimized by extracting common code into shared methods.
* Test infrastructure improved with better fixture loading and mock support.

## Added

* `SessionData` class for encapsulating session initialization parameters.
* `SdkConfiguration` class for SDK configuration options (replaces individual parameters).
* `encryptTokenRequest(_:success:failure:)` method for tokenization support.
* `currencyConversionQuote(amountOfMoney:partialCardNumber:paymentProductId:success:failure:)` and `currencyConversionQuote(amountOfMoney:token:success:failure:)` methods for Dynamic Currency Conversion.

## Migration Guide

To migrate from version 4.x to 5.0.0:

1. **Update initialization code:**
   * Replace `Session` with `OnlinePaymentsSdk`
   * Wrap session parameters in `SessionData` object
   * Wrap configuration parameters in `SdkConfiguration` object
   * Handle the throwing initializer with `try`

2. **Update method calls:**
   * Replace all `session.*` calls with `sdk.*` calls
   * Remove `groupPaymentProducts` parameter from `paymentItems` calls
   * Rename `paymentItems(for:...)` to `basicPaymentProducts(forContext:...)`
   * Update parameter names: `context:` → `paymentContext:`
   * Merge `failure` and `apiFailure` callbacks into a single `failure` callback
   * Rename `prepare(_:...)` to `encryptPaymentRequest(_:...)`

3. **Update type references:**
   * Replace `BasicPaymentProduct.identifier` with `BasicPaymentProduct.id`
   * Replace `PaymentProduct.identifier` with `PaymentProduct.id`
   * Update payment product ID comparisons to use `Int?` instead of `String`

4. **Update PaymentRequest usage:**
   * Change `setValue(forField:value:)` to `field(id:).setValue(value:)` with error handling

For more information, follow the instructions provided in the README.md file.

# 4.2.3

## Changed

* Changed the project's Swift explicit minimum version compatibility to 5.3.

# 4.2.2

## Changed

* Rebuilt the project with the Xcode 26.0.1 (17A400) and Swift 6.2.
* The library is now built with the `BUILD_FOR_DISTRIBUTION` flag.

# 4.2.1

## Changed

* Renamed internal properties of Validators for compatibility reasons. Since this is an internal class, it should not
  affect any consumer.
* The expiration date validator now accepts values in MMyy and MMyyyy formats, but the validation still depends on the 
  specific payment product `expiryDate` field validation rules returned from the API.

# 4.2.0

## Changed

Filtering of payment products that cannot be sent in the encrypted customer input has been added to C2sCommunicator. The
following methods are currently unsupported:

* Maestro (117)
* Intersolve (5700)
* Sodexo & Sport Culture (5772)
* VVV Giftcard (5784)

## Deprecated

* `PaymentContext.locale` has been marked deprecated and should not be used anymore, since it does not influence
  behavior.

# 4.1.1

## Changed

* The `PaymentRequest` object now accepts both masked and unmasked values.

# 4.1.0

## Changed

* Set encryption to r`saEncryptionOAEPSHA1`.
* Improve readability of `C2SCommunicator`.
* Fix Alamofire wrapper by removing deprecated calls.

# 4.0.1

## Changed

* The `AccountOnFile` id property in the Payment Request JSON is now stored as string.

# 4.0.0

## Changed

The minimal supported iOS version of the SDK is now 15.6.

Members access modifiers are changed for the following:

* `Session.clientSessionId` has been made internal.
* `decimalRegex`, `lowerAlphaRegex`, `upperAlphaRegex` has been made internal of the class `StringFormatter`.
* `numberFormatter` and `numericStringCheck` has been made private of the class `PaymentProductField`.

Payment products do not have `displayHints` and `displayHintsList` anymore. `displayHintsList` has been removed and
`displayHints` is now `List`. Affected classes: `PaymentProductGroup`, `BasicPaymentProduct`,
`BasicPaymentProductGroup`, `BasicPaymentItem`.

In the `Session` class, parameter `groupPaymentProducts` has been removed from the `paymentItems` method (
`@objc paymentItemsForContext`) since it was not being used.

Encryption methods now throw `EncryptionError` when something is not correct.

All tests have been updated to reflect the changes.

## Deleted

The following deprecated members have been removed:

* `ApiErrorItem.code`; use `errorCode` instead.
* `AccountOnFileAttribute.mustWriteReason`; no replacement needed.
* `PreferredInputType.noKeyboard`; no replacement needed.
* `AmountOfMoney.currencyCodeString`; use `currencyCode` instead.
* `PaymentContext.countryCodeString`; use `countryCode` instead.
* `IINDetailsResponse.countryCodeString`; use `countryCode` instead.
* `FormElement.valueMapping`; no replacement needed.
* `PaymentProductField.usedForLookup`; no replacement needed.
* `PaymentProductField.errors`; use `errorMessageIds` instead.
* `PaymentProductField.validateValue(value: String, for request: PaymentRequest)`; use `validateValue(value:)` or
  `validateValue(for:)`.
* `PaymentProductFieldDisplayHints.link`; no replacement needed.
* `ToolTip.imagePath` and `ToolTip.image` ; no replacement needed.
* `PaymentRequest.errors`; use `errorMessageIds` instead.
* method `validate(value:, for request:)` from **all** validators; use `validate(field:in:)` instead.
* `SDKConstants.kSDKLocalizable`; no replacement needed since no localization is provided.

The following classes have been removed:

* `DisplayElement`
* `ValueMappingItem`

The `init?(json: [String: Any])` method has been removed from the following classes:

* `AccountOnFile`
* `AccountOnFileAttribute`
* `AmountOfMoney`
* `IINDetail`
* `IINDetailsResponse`
* `BasicPaymentProduct`
* `BasicPaymentProducts`
* `BasicPaymentProductGroup`
* `BasicPaymentProductGroups`
* `DataRestrictions`
* `FormElement`
* `LabelTemplateItem`
* `PaymentProduct`
* `PaymentProductField`
* `PaymentProductFieldDisplayHints`
* `PaymentProductGroup`
* `ToolTip`
* `Surcharge`
* `SurchargeCalculationResponse`
* `ValidatorFixedList`
* `ValidatorLength`
* `ValidatorRange`
* `ValidatorRegularExpression`

Several (Objective-C) deprecated methods from the `Session` class have been removed:

* `paymentProductNetworks(forProductId:context:success:failure:)`; use
  `paymentProductNetworks(forProductId:context:success:failure:apiFailure:)` instead.
* `paymentProducts(context:success:failure)`; use `paymentProductsForContext(context:success:failure:apiFailure:)`
  instead.
* `paymentItemsForContext(groupPaymentProducts:success:failure:)`; use
  `paymentItemsForContext(groupPaymentProducts:success:failure:apiFailure:)` instead.
* `paymentProductWithId(context:success:failure:)`; use `paymentProductWithId(context:success:failure:apiFailure:)`
  instead.
* `IINDetailsForPartialCreditCardNumber(context:success:failure:)`; use
  `IINDetailsForPartialCreditCardNumber(context:success:failure:apiFailure:)` instead.
* `publicKeyWithSuccess(failure:)`; use `publicKeyWithSuccess(:failure:apiFailure:)`
* `preparePaymentRequest(success:failure:)`; use `preparePaymentRequest(success:failure:apiFailure:)` instead.
* `surchargeCalculation(amountOfMoney:partialCreditCardNumber:paymentProductId:success:failure:)`; use
  `surchargeCalculation(amountOfMoney:partialCreditCardNumber:paymentProductId:success:failure:apiFailure:)` instead.
* `surchargeCalculation(amountOfMoney:token:success:failure:)`; use
  `surchargeCalculation(amountOfMoney:token:success:failure:apiFailure:)` instead.
