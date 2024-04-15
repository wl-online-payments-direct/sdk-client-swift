//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

@objc(OPSession)
public class Session: NSObject {
    @available(*, deprecated, message: "In a future release, this property will become internal to the SDK.")
    @objc public var clientSessionId: String {
        return communicator.clientSessionId
    }
    private var communicator: C2SCommunicator
    private var encryptor: Encryptor
    private var joseEncryptor: JOSEEncryptor
    private var stringFormatter: StringFormatter

    private var paymentProducts = BasicPaymentProducts()

    internal var paymentProductMapping = [AnyHashable: Any]()

    private var baseURL: String {
        return communicator.baseURL
    }

    private var assetsBaseURL: String {
        return communicator.assetsBaseURL
    }

    internal var iinLookupPending = false

    @objc public var loggingEnabled: Bool {
        get {
            return communicator.loggingEnabled
        }
        set {
            communicator.configuration.loggingEnabled = newValue
        }
    }

    internal init(
        communicator: C2SCommunicator,
        encryptor: Encryptor,
        JOSEEncryptor: JOSEEncryptor,
        stringFormatter: StringFormatter
    ) {
        self.communicator = communicator
        self.encryptor = encryptor
        self.joseEncryptor = JOSEEncryptor
        self.stringFormatter = stringFormatter
    }

    @objc public init(
        clientSessionId: String,
        customerId: String,
        baseURL: String,
        assetBaseURL: String,
        appIdentifier: String,
        loggingEnabled: Bool = false,
        sdkIdentifier: String
    ) {
        let stringFormatter = StringFormatter()
        let encryptor = Encryptor()
        let configuration = C2SCommunicatorConfiguration(clientSessionId: clientSessionId,
                                                         customerId: customerId,
                                                         baseURL: baseURL,
                                                         assetBaseURL: assetBaseURL,
                                                         appIdentifier: appIdentifier,
                                                         loggingEnabled: loggingEnabled,
                                                         sdkIdentifier: sdkIdentifier)
        let communicator = C2SCommunicator(configuration: configuration)
        let jsonEncryptor = JOSEEncryptor(encryptor: encryptor)

        self.communicator = communicator
        self.encryptor = encryptor
        self.joseEncryptor = jsonEncryptor
        self.stringFormatter = stringFormatter
    }

    @objc public convenience init(
        clientSessionId: String,
        customerId: String,
        baseURL: String,
        assetBaseURL: String,
        appIdentifier: String,
        loggingEnabled: Bool = false
    ) {
        self.init(clientSessionId: clientSessionId,
                  customerId: customerId,
                  baseURL: baseURL,
                  assetBaseURL: assetBaseURL,
                  appIdentifier: appIdentifier,
                  loggingEnabled: loggingEnabled,
                  sdkIdentifier: SDKConstants.kSDKIdentifier
        )
    }

    @objc public static func session(
        clientSessionId: String,
        customerId: String,
        baseURL: String,
        assetBaseURL: String,
        appIdentifier: String,
        loggingEnabled: Bool = false
    ) -> Session {
        return
            Session.init(
                clientSessionId: clientSessionId,
                customerId: customerId,
                baseURL: baseURL,
                assetBaseURL: assetBaseURL,
                appIdentifier: appIdentifier,
                loggingEnabled: loggingEnabled
            )
    }

    @objc(paymentProductsForContext:success:failure:apiFailure:)
    public func paymentProducts(
        for context: PaymentContext,
        success: ((_ paymentProducts: BasicPaymentProducts) -> Void)? = nil,
        failure: ((_ error: Error) -> Void)? = nil,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        communicator.paymentProducts(
            forContext: context,
            success: { paymentProducts in
                self.paymentProducts = paymentProducts
                self.paymentProducts.stringFormatter = self.stringFormatter
                self.setLogoForPaymentItems(for: paymentProducts.paymentProducts) {
                    success?(paymentProducts)
                }
            },
            failure: { error in
                failure?(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    @objc public func paymentProductNetworks(
        forProductId paymentProductId: String,
        context: PaymentContext,
        success: ((_ paymentProductNetworks: PaymentProductNetworks) -> Void)? = nil,
        failure: ((_ error: Error) -> Void)? = nil,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        communicator.paymentProductNetworks(
            forProduct: paymentProductId,
            context: context,
            success: { paymentProductNetworks in
                success?(paymentProductNetworks)
            },
            failure: { error in
                failure?(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    // swiftlint:disable todo
    // TODO: SMBO-96367 - Parameter 'groupPaymentProducts' is unused
    // swiftlint:enable todo
    @objc(paymentItemsForContext:groupPaymentProducts:success:failure:apiFailure:)
    public func paymentItems(
        for context: PaymentContext,
        groupPaymentProducts: Bool,
        success: ((_ paymentItems: PaymentItems) -> Void)? = nil,
        failure: ((_ error: Error) -> Void)? = nil,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        communicator.paymentProducts(
            forContext: context,
            success: { paymentProducts in
                if paymentProducts.paymentProducts.isEmpty {
                    let items = PaymentItems(products: paymentProducts, groups: nil)
                    success?(items)
                }
                self.paymentProducts = paymentProducts
                self.paymentProducts.stringFormatter = self.stringFormatter
                self.setLogoForPaymentItems(for: paymentProducts.paymentProducts) {
                    let items = PaymentItems(products: paymentProducts, groups: nil)
                    success?(items)
                }
            },
            failure: { error in
                failure?(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    @objc public func paymentProduct(
        withId paymentProductId: String,
        context: PaymentContext,
        success: ((_ paymentProduct: PaymentProduct) -> Void)? = nil,
        failure: ((_ error: Error) -> Void)? = nil,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        let key = "\(paymentProductId)-\(context.description)"

        if let paymentProduct = paymentProductMapping[key] as? PaymentProduct {
            success?(paymentProduct)
        } else {
            communicator.paymentProduct(
                withIdentifier: paymentProductId,
                context: context,
                success: { paymentProduct in
                    self.paymentProductMapping[key] = paymentProduct
                    self.setTooltipImages(for: paymentProduct) {}
                    self.setLogoForDisplayHints(for: paymentProduct.displayHints) {}
                    self.setLogoForDisplayHintsList(for: paymentProduct.displayHintsList) {
                        success?(paymentProduct)
                    }
                },
                failure: { error in
                    failure?(error)
                },
                apiFailure: { errorResponse in
                    apiFailure?(errorResponse)
                }
            )
        }
    }

    @objc(IINDetailsForPartialCreditCardNumber:context:success:failure:apiFailure:)
    public func iinDetails(forPartialCreditCardNumber partialCreditCardNumber: String,
                           context: PaymentContext?,
                           success: ((_ iinDetailsResponse: IINDetailsResponse) -> Void)? = nil,
                           failure: ((_ error: Error) -> Void)? = nil,
                           apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        if partialCreditCardNumber.count < 6 {
            let response = IINDetailsResponse(status: .notEnoughDigits)
            success?(response)
        } else {
            iinLookupPending = true
            communicator.paymentProductId(
                byPartialCreditCardNumber: partialCreditCardNumber,
                context: context,
                success: { response in
                    self.iinLookupPending = false
                    success?(response)
                },
                failure: { error in
                    self.iinLookupPending = false
                    failure?(error)
                },
                apiFailure: { errorResponse in
                    apiFailure?(errorResponse)
                }
            )
        }

    }

    @objc(publicKeyWithSuccess:failure:apiFailure:)
    public func publicKey(
        success: ((_ publicKeyResponse: PublicKeyResponse) -> Void)? = nil,
        failure: ((_ error: Error) -> Void)? = nil,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        communicator.publicKey(
            success: { publicKeyResponse in
                success?(publicKeyResponse)
            },
            failure: { error in
                failure?(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )

    }

    @objc(preparePaymentRequest:success:failure:apiFailure:)
    public func prepare(
        _ paymentRequest: PaymentRequest,
        success: ((_ preparedPaymentRequest: PreparedPaymentRequest) -> Void)? = nil,
        failure: ((_ error: Error) -> Void)? = nil,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        self.publicKey(
            success: { publicKeyResponse in
                let publicKeyAsData = publicKeyResponse.encodedPublicKey.decode()
                guard let strippedPublicKeyAsData = self.encryptor.stripPublicKey(data: publicKeyAsData) else {
                    failure?(EncryptDataError.publicKeyDecodeError)
                    return
                }
                let tag = "globalcollect-sdk-public-key-swift"

                self.encryptor.deleteRSAKey(withTag: tag)
                self.encryptor.storePublicKey(publicKey: strippedPublicKeyAsData, tag: tag)

                guard let publicKey = self.encryptor.RSAKey(withTag: tag) else {
                    failure?(EncryptDataError.rsaKeyNotFound)
                    return
                }

                let paymentRequestJSON =
                    self.preparePaymentRequestJSON(
                        forClientSessionId: self.clientSessionId,
                        paymentRequest: paymentRequest
                    )
                let encryptedFields =
                    self.joseEncryptor.encryptToCompactSerialization(
                        JSON: paymentRequestJSON,
                        withPublicKey: publicKey,
                        keyId: publicKeyResponse.keyId
                    )
                let encodedClientMetaInfo = self.communicator.base64EncodedClientMetaInfo
                let preparedRequest =
                    PreparedPaymentRequest(
                        encryptedFields: encryptedFields,
                        encodedClientMetaInfo: encodedClientMetaInfo
                    )

                success?(preparedRequest)
            },
            failure: { error in
                failure?(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    private func preparePaymentRequestJSON(
        forClientSessionId clientSessionId: String,
        paymentRequest: PaymentRequest
    ) -> String {
        var paymentRequestJSON = String()

        guard let paymentProduct = paymentRequest.paymentProduct else {
            NSException(
                name: NSExceptionName(rawValue: "Invalid payment product"),
                reason: "Payment product is invalid"
            ).raise()
            // Return is mandatory but will never be reached because of the exception above.
            return "Invalid payment product"
        }

        let clientSessionId = "{\"clientSessionId\": \"\(clientSessionId)\", "
        paymentRequestJSON += clientSessionId
        let nonce = "\"nonce\": \"\(self.encryptor.generateUUID())\", "
        paymentRequestJSON += nonce
        let paymentProductJSON = "\"paymentProductId\": \(paymentProduct.identifier), "
        paymentRequestJSON += paymentProductJSON

        if let accountOnFile = paymentRequest.accountOnFile {
            paymentRequestJSON += "\"accountOnFileId\": \(accountOnFile.identifier), "
        }
        if paymentRequest.tokenize {
            let tokenize = "\"tokenize\": true, "
            paymentRequestJSON += tokenize
        }
        if let fieldVals = paymentRequest.unmaskedFieldValues,
           let values = self.keyValueJSONFromDictionary(dictionary: fieldVals) {
            let paymentValues = "\"paymentValues\": \(values)}"
            paymentRequestJSON += paymentValues
        }

        return paymentRequestJSON
    }

    @objc public func currencyConversionQuote(
        amountOfMoney: AmountOfMoney,
        partialCreditCardNumber: String,
        paymentProductId: NSNumber? = nil,
        success: ((_ currencyConversionResponse: CurrencyConversionResponse) -> Void)? = nil,
        failure: ((_ error: Error) -> Void)? = nil,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        let card = Card(cardNumber: partialCreditCardNumber, paymentProductId: paymentProductId?.intValue)
        let cardSource = CardSource(card: card)

        communicator.currencyConversionQuote(
            amountOfMoney: amountOfMoney,
            cardSource: cardSource,
            success: { response in
                success?(response)
            },
            failure: { error in
                failure?(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            })
    }

    @objc public func currencyConversionQuote(
        amountOfMoney: AmountOfMoney,
        token: String,
        success: ((_ currencyConversionResponse: CurrencyConversionResponse) -> Void)? = nil,
        failure: ((_ error: Error) -> Void)? = nil,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        let cardSource = CardSource(token: token)

        communicator.currencyConversionQuote(
            amountOfMoney: amountOfMoney,
            cardSource: cardSource,
            success: { response in
                success?(response)
            },
            failure: { error in
                failure?(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    @objc public func surchargeCalculation(
        amountOfMoney: AmountOfMoney,
        partialCreditCardNumber: String,
        paymentProductId: NSNumber? = nil,
        success: ((_ surchargeCalculationResponse: SurchargeCalculationResponse) -> Void)? = nil,
        failure: ((_ error: Error) -> Void)? = nil,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        let card = Card(cardNumber: partialCreditCardNumber, paymentProductId: paymentProductId?.intValue)
        let cardSource = CardSource(card: card)

        communicator.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            cardSource: cardSource,
            success: { response in
                success?(response)
            },
            failure: { error in
                failure?(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    @objc public func surchargeCalculation(
        amountOfMoney: AmountOfMoney,
        token: String,
        success: ((_ surchargeCalculationResponse: SurchargeCalculationResponse) -> Void)? = nil,
        failure: ((_ error: Error) -> Void)? = nil,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        let cardSource = CardSource(token: token)

        communicator.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            cardSource: cardSource,
            success: { response in
                success?(response)

            },
            failure: { error in
                failure?(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    private func keyValuePairs(from dictionary: [String: String]) -> [[String: String]] {
        var keyValuePairs = [[String: String]]()
        for (key, value) in  dictionary {
            let pair = ["key": key, "value": value]
            keyValuePairs.append(pair)
        }
        return keyValuePairs
    }

    private func keyValueJSONFromDictionary(dictionary: [String: String]) -> String? {
        let keyValuePairs = self.keyValuePairs(from: dictionary)
        guard let JSONAsData = try? JSONSerialization.data(withJSONObject: keyValuePairs) else {
            Macros.DLog(message: "Unable to create JSON data from dictionary")
            return nil
        }

        return String(bytes: JSONAsData, encoding: String.Encoding.utf8)
    }

    private func setLogoForPaymentItems(for paymentItems: [BasicPaymentItem], completion: @escaping() -> Void) {
        var counter = 0
        for paymentItem in paymentItems {
            setLogoForDisplayHints(for: paymentItem.displayHints, completion: {})
            if paymentItem.displayHintsList.isEmpty == false {
                setLogoForDisplayHintsList(for: paymentItem.displayHintsList, completion: {
                    counter += 1
                    if counter == paymentItems.count {
                        completion()
                    }
                })
            } else {
                counter += 1
                if counter == paymentItems.count {
                    completion()
                }
            }
        }
    }

    internal func setLogoForDisplayHints(for displayHints: PaymentItemDisplayHints, completion: @escaping() -> Void) {
        self.getLogoByStringURL(from: displayHints.logoPath) { data, _, error in
            if let imageData = data, error == nil {
                displayHints.logoImage = UIImage(data: imageData)
            }
            completion()
        }
    }

    internal func setLogoForDisplayHintsList(
        for displayHints: [PaymentItemDisplayHints],
        completion: @escaping() -> Void
    ) {
        var counter = 0
        for displayHint in displayHints {
            self.getLogoByStringURL(from: displayHint.logoPath) { data, _, error in
                counter += 1
                if let imageData = data, error == nil {
                    displayHint.logoImage = UIImage(data: imageData)
                }
                if counter == displayHints.count {
                    completion()
                }
            }
        }
    }

    private func setTooltipImages(for paymentItem: PaymentItem, completion: @escaping() -> Void) {
        for field in paymentItem.fields.paymentProductFields {
            guard let tooltip = field.displayHints.tooltip,
                  let imagePath = tooltip.imagePath else { return }

            self.getLogoByStringURL(from: imagePath) { data, _, error in
                if let imageData = data, error == nil {
                    tooltip.image = UIImage(data: imageData)
                }
            }
        }
    }

    internal func getLogoByStringURL(
        from url: String,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        guard let encodedUrlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            Macros.DLog(message: "Unable to decode URL for url string: \(url)")
            completion(nil, nil, nil)
            return
        }

        guard let encodedUrl = URL(string: encodedUrlString) else {
            Macros.DLog(message: "Unable to create URL for url string: \(encodedUrlString)")
            completion(nil, nil, nil)
            return
        }

        URLSession.shared.dataTask(with: encodedUrl, completionHandler: {data, response, error in
            DispatchQueue.main.async {
                completion(data, response, error)
            }
        }).resume()
    }

    // MARK: Functions only available for Objective-C

    @available(swift, obsoleted: 1.0)
    @available(*, deprecated, message: "Use paymentProductsForContext:success:failure:apiFailure: instead.")
    @objc
    public func paymentProducts(
        for context: PaymentContext,
        success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        self.paymentProducts(for: context, success: success, failure: failure, apiFailure: nil)
    }

    @available(swift, obsoleted: 1.0)
    @available(
        *,
        deprecated,
        message: "Use paymentProductNetworksForProductId:context:success:failure:apiFailure: instead."
    )
    @objc
    public func paymentProductNetworks(
        forProductId paymentProductId: String,
        context: PaymentContext,
        success: @escaping (_ paymentProductNetworks: PaymentProductNetworks) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        self.paymentProductNetworks(
            forProductId: paymentProductId,
            context: context,
            success: success,
            failure: failure,
            apiFailure: nil
        )
    }

    @available(swift, obsoleted: 1.0)
    @available(
        *,
        deprecated,
        message: "paymentItemsForContext:groupPaymentProducts:success:failure:apiFailure: instead."
    )
    @objc(paymentItemsForContext:groupPaymentProducts:success:failure:)
    public func paymentItems(
        for context: PaymentContext,
        groupPaymentProducts: Bool,
        success: @escaping (_ paymentItems: PaymentItems) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        self.paymentItems(for: context, groupPaymentProducts: groupPaymentProducts, success: success, failure: failure)
    }

    @available(swift, obsoleted: 1.0)
    @available(*, deprecated, message: "Use paymentProductWithId:context:success:failure:apiFailure: instead.")
    @objc
    public func paymentProduct(
        withId paymentProductId: String,
        context: PaymentContext,
        success: @escaping (_ paymentProduct: PaymentProduct) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        self.paymentProduct(
            withId: paymentProductId,
            context: context,
            success: success,
            failure: failure,
            apiFailure: nil
        )
    }

    @available(swift, obsoleted: 1.0)
    @available(
        *,
        deprecated,
        message: "Use IINDetailsForPartialCreditCardNumber:context:success:failure:apiFailure: instead."
    )
    @objc(IINDetailsForPartialCreditCardNumber:context:success:failure:)
    public func iinDetails(forPartialCreditCardNumber partialCreditCardNumber: String,
                           context: PaymentContext?,
                           success: @escaping (_ iinDetailsResponse: IINDetailsResponse) -> Void,
                           failure: @escaping (_ error: Error) -> Void
    ) {
        self.iinDetails(
            forPartialCreditCardNumber: partialCreditCardNumber,
            context: context,
            success: success,
            failure: failure,
            apiFailure: nil
        )
    }

    @available(swift, obsoleted: 1.0)
    @available(*, deprecated, message: "Use publicKeyWithSuccess:failure:apiFailure: instead.")
    @objc(publicKeyWithSuccess:failure:)
    public func publicKey(
        success: @escaping (_ publicKeyResponse: PublicKeyResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        self.publicKey(success: success, failure: failure, apiFailure: nil)
    }

    @available(swift, obsoleted: 1.0)
    @available(*, deprecated, message: "Use preparePaymentRequest:success:failure:apiFailure: instead.")
    @objc(preparePaymentRequest:success:failure:)
    public func prepare(
        _ paymentRequest: PaymentRequest,
        success: @escaping (_ preparedPaymentRequest: PreparedPaymentRequest) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        self.prepare(paymentRequest, success: success, failure: failure, apiFailure: nil)
    }

    @available(swift, obsoleted: 1.0)
    @available(
        *,
        deprecated,
        message: """
        Use
        surchargeCalculation:amountOfMoney:partialCreditCardNumber:paymentProductId:success:failure:apiFailure:
        instead.
        """
    )
    @objc
    public func surchargeCalculation(
        amountOfMoney: AmountOfMoney,
        partialCreditCardNumber: String,
        paymentProductId: NSNumber? = nil,
        success: @escaping (_ surchargeCalculationResponse: SurchargeCalculationResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        self.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            partialCreditCardNumber: partialCreditCardNumber,
            success: success,
            failure: failure,
            apiFailure: nil
        )
    }

    @available(swift, obsoleted: 1.0)
    @available(
        *,
        deprecated,
        message: "Use surchargeCalculation:amountOfMoney:token:success:failure:apiFailure: instead."
    )
    @objc
    public func surchargeCalculation(
        amountOfMoney: AmountOfMoney,
        token: String,
        success: @escaping (_ surchargeCalculationResponse: SurchargeCalculationResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        self.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            token: token,
            success: success,
            failure: failure,
            apiFailure: nil
        )
    }
}
