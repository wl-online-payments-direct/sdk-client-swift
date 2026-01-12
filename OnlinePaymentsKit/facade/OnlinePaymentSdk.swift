/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation

/// Main entry point for the Online Payments SDK.
///
/// The `OnlinePaymentsSdk` provides a unified interface for processing online payments,
/// including retrieving payment products, obtaining IIN details, calculating surcharges,
/// and encrypting payment requests.
///
/// ## Usage Example
/// ```swift
/// let sessionData = SessionData(
///     clientSessionId: "session-123",
///     customerId: "customer-456",
///     clientApiUrl: "https://api.example.com",
///     assetUrl: "https://assets.example.com"
/// )
///
/// let sdk = try OnlinePaymentsSdk(sessionData: sessionData)
/// ```
@objc(OPOnlinePaymentsSdk)
public class OnlinePaymentsSdk: NSObject {

    // MARK: - Private Properties

    private let encryptionService: EncryptionServiceProtocol
    private let paymentProductService: PaymentProductServiceProtocol
    private let clientService: ClientServiceProtocol

    // MARK: - Initialization

    /// Initializes the SDK with session data and optional configuration.
    ///
    /// - Parameters:
    ///   - sessionData: Session information including client session ID, customer ID, and API URLs.
    ///   - configuration: Optional SDK configuration. If not provided, default configuration will be used.
    /// - Throws: `SdkError` if session data validation fails.
    @objc
    public convenience init(
        sessionData: SessionData,
        configuration: SdkConfiguration? = nil
    ) throws {
        try self.init(
            sessionData: sessionData,
            configuration: configuration,
            factory: nil
        )
    }

    /// Internal initializer with dependency injection support for testing.
    ///
    /// - Parameters:
    ///   - sessionData: Session information including client session ID, customer ID, and API URLs.
    ///   - configuration: Optional SDK configuration.
    ///   - factory: Service factory for creating SDK services. If nil, a default factory will be created.
    /// - Throws: `SdkError` if session data validation fails.
    internal init(
        sessionData: SessionData,
        configuration: SdkConfiguration?,
        factory: ServiceFactoryProtocol?
    ) throws {
        let normalizedSessionData = try SessionNormalizer.normalize(sessionData)

        let serviceFactory =
            factory
            ?? ServiceFactory(
                sessionData: normalizedSessionData,
                configuration: configuration
            )

        self.encryptionService = serviceFactory.getEncryptionService()
        self.paymentProductService = serviceFactory.getPaymentProductService()
        self.clientService = serviceFactory.getClientService()

        super.init()
    }

    // MARK: - Payment Products

    /// Retrieves basic information about available payment products.
    ///
    /// Basic payment products contain essential information such as product ID, label, and logo.
    /// Use this method to display a list of available payment options to the user.
    ///
    /// - Parameters:
    ///   - paymentContext: Context information including amount, currency, and country code.
    ///   - success: Closure called with the list of basic payment products if the request succeeds.
    ///   - failure: Closure called with an error if the request fails.
    @objc(basicPaymentProductsForContext:success:failure:)
    public func basicPaymentProducts(
        forContext paymentContext: PaymentContext,
        success: @escaping (_ products: BasicPaymentProducts) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    ) {
        paymentProductService.paymentProducts(
            forContext: paymentContext,
            success: success,
            failure: failure
        )
    }

    /// Retrieves detailed information about a specific payment product.
    ///
    /// Detailed payment product information includes all fields required to collect payment data,
    /// validation rules, display hints, and more.
    ///
    /// - Parameters:
    ///   - paymentProductId: The unique identifier of the payment product.
    ///   - paymentContext: Context information including amount, currency, and country code.
    ///   - success: Closure called with the payment product details if the request succeeds.
    ///   - failure: Closure called with an error if the request fails.
    @objc
    public func paymentProduct(
        withId paymentProductId: Int,
        paymentContext: PaymentContext,
        success: @escaping (_ product: PaymentProduct) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    ) {
        paymentProductService.paymentProduct(
            withId: paymentProductId,
            forContext: paymentContext,
            success: success,
            failure: failure
        )
    }

    /// Retrieves the payment product networks (e.g., Visa, Mastercard) for a specific payment product.
    ///
    /// This is particularly useful for payment products that support multiple card networks,
    /// such as co-branded cards.
    ///
    /// - Parameters:
    ///   - paymentProductId: The unique identifier of the payment product.
    ///   - paymentContext: Context information including amount, currency, and country code.
    ///   - success: Closure called with the payment product networks if the request succeeds.
    ///   - failure: Closure called with an error if the request fails.
    @objc
    public func paymentProductNetworks(
        forProductId paymentProductId: Int,
        paymentContext: PaymentContext,
        success: @escaping (_ networks: PaymentProductNetworks) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    ) {
        paymentProductService.paymentProductNetworks(
            forProductId: paymentProductId,
            forContext: paymentContext,
            success: success,
            failure: failure
        )
    }

    // MARK: - IIN Details

    /// Retrieves IIN (Issuer Identification Number) details for a partial credit card number.
    ///
    /// IIN details provide information about the card issuer, such as the payment product ID,
    /// country code, and whether the card is allowed in the current payment context.
    ///
    /// The partial credit card number should be at least 6 digits to obtain valid IIN details.
    ///
    /// - Parameters:
    ///   - partialCardNumber: The first 6-8 digits of the credit card number.
    ///   - paymentContext: Context information including amount, currency, and country code.
    ///   - success: Closure called with the IIN details if the request succeeds.
    ///   - failure: Closure called with an error if the request fails.
    @objc(IINDetailsForPartialCardNumber:context:success:failure:)
    public func iinDetails(
        forPartialCardNumber partialCardNumber: String,
        paymentContext: PaymentContext,
        success: @escaping (_ response: IINDetailsResponse) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    ) {
        clientService.iinDetails(
            forBin: partialCardNumber,
            forContext: paymentContext,
            success: success,
            failure: failure
        )
    }

    // MARK: - Surcharge Calculation

    /// Calculates surcharge for a payment using a partial credit card number.
    ///
    /// Surcharges are additional fees that may be applied to certain payment methods.
    /// This method calculates the surcharge amount based on the payment amount and card details.
    ///
    /// - Parameters:
    ///   - amountOfMoney: The payment amount and currency.
    ///   - partialCardNumber: The first 6-8 digits of the credit card number.
    ///   - paymentProductId: Optional payment product identifier. If not provided, it will be determined from the card number.
    ///   - success: Closure called with the surcharge calculation response if the request succeeds.
    ///   - failure: Closure called with an error if the request fails.
    @objc
    public func surchargeCalculation(
        amountOfMoney: AmountOfMoney,
        partialCardNumber: String,
        paymentProductId: NSNumber? = nil,
        success: @escaping (_ response: SurchargeCalculationResponse) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    ) {
        let card = Card(
            cardNumber: partialCardNumber,
            paymentProductId: paymentProductId?.intValue
        )
        let cardSource = CardSource(card: card)

        clientService.surchargeCalculation(
            withAmountOfMoney: amountOfMoney,
            forCardSource: cardSource,
            success: success,
            failure: failure
        )
    }

    /// Calculates surcharge for a payment using a tokenized card.
    ///
    /// Surcharges are additional fees that may be applied to certain payment methods.
    /// This method calculates the surcharge amount based on the payment amount and tokenized card.
    ///
    /// - Parameters:
    ///   - amountOfMoney: The payment amount and currency.
    ///   - token: The tokenized card identifier.
    ///   - success: Closure called with the surcharge calculation response if the request succeeds.
    ///   - failure: Closure called with an error if the request fails.
    @objc
    public func surchargeCalculation(
        amountOfMoney: AmountOfMoney,
        token: String,
        success: @escaping (_ response: SurchargeCalculationResponse) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    ) {
        let cardSource = CardSource(token: token)

        clientService.surchargeCalculation(
            withAmountOfMoney: amountOfMoney,
            forCardSource: cardSource,
            success: success,
            failure: failure
        )
    }

    // MARK: - Currency Conversion

    /// Retrieves a currency conversion quote for a payment using a partial credit card number.
    ///
    /// Dynamic Currency Conversion (DCC) allows customers to see the transaction amount
    /// in their home currency during checkout.
    ///
    /// - Parameters:
    ///   - amountOfMoney: The payment amount and currency.
    ///   - partialCardNumber: The first 6-8 digits of the credit card number.
    ///   - paymentProductId: Optional payment product identifier. If not provided, it will be determined from the card number.
    ///   - success: Closure called with the currency conversion quote if the request succeeds.
    ///   - failure: Closure called with an error if the request fails.
    @objc
    public func currencyConversionQuote(
        amountOfMoney: AmountOfMoney,
        partialCardNumber: String,
        paymentProductId: NSNumber? = nil,
        success: @escaping (_ response: CurrencyConversionResponse) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    ) {
        let card = Card(
            cardNumber: partialCardNumber,
            paymentProductId: paymentProductId?.intValue
        )
        let cardSource = CardSource(card: card)

        clientService.currencyConversionQuote(
            withAmountOfMoney: amountOfMoney,
            forCardSource: cardSource,
            success: success,
            failure: failure
        )
    }

    /// Retrieves a currency conversion quote for a payment using a tokenized card.
    ///
    /// Dynamic Currency Conversion (DCC) allows customers to see the transaction amount
    /// in their home currency during checkout.
    ///
    /// - Parameters:
    ///   - amountOfMoney: The payment amount and currency.
    ///   - token: The tokenized card identifier.
    ///   - success: Closure called with the currency conversion quote if the request succeeds.
    ///   - failure: Closure called with an error if the request fails.
    @objc
    public func currencyConversionQuote(
        amountOfMoney: AmountOfMoney,
        token: String,
        success: @escaping (_ response: CurrencyConversionResponse) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    ) {
        let cardSource = CardSource(token: token)

        clientService.currencyConversionQuote(
            withAmountOfMoney: amountOfMoney,
            forCardSource: cardSource,
            success: success,
            failure: failure
        )
    }

    // MARK: - Encryption

    /// Retrieves the public key used for encrypting payment data.
    ///
    /// The public key is required to encrypt sensitive payment information before
    /// sending it to the server. The key should be cached and reused for multiple
    /// encryption operations until it expires.
    ///
    /// - Parameters:
    ///   - success: Closure called with the public key response if the request succeeds.
    ///   - failure: Closure called with an error if the request fails.
    @objc
    public func publicKey(
        success: @escaping (_ publicKeyResponse: PublicKeyResponse) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    ) {
        encryptionService.getPublicKey(
            success: success,
            failure: failure
        )
    }

    /// Encrypts a payment request with sensitive payment data.
    ///
    /// This method encrypts all sensitive payment information (card number, CVV, etc.)
    /// using the public key obtained from `getPublicKey()`. The encrypted request
    /// can then be safely transmitted to your server.
    ///
    /// - Parameters:
    ///   - request: The payment request containing unencrypted payment data.
    ///   - success: Closure called with the encrypted request if encryption succeeds.
    ///   - failure: Closure called with an error if encryption fails.
    @objc
    public func encryptPaymentRequest(
        _ request: PaymentRequest,
        success: @escaping (_ encryptedRequest: EncryptedRequest) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    ) {
        encryptionService.encryptPaymentRequest(
            request,
            success: success,
            failure: failure
        )
    }

    /// Encrypts a token request for credit card tokenization.
    ///
    /// This method encrypts credit card information to create a token that can be
    /// stored and reused for future payments. The token request is encrypted using
    /// the public key obtained from `getPublicKey()`.
    ///
    /// - Parameters:
    ///   - request: The token request containing credit card details.
    ///   - success: Closure called with the encrypted request if encryption succeeds.
    ///   - failure: Closure called with an error if encryption fails.
    @objc
    public func encryptTokenRequest(
        _ request: CreditCardTokenRequest,
        success: @escaping (_ encryptedRequest: EncryptedRequest) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    ) {
        encryptionService.encryptTokenRequest(
            request,
            success: success,
            failure: failure
        )
    }
}
