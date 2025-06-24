//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

@objc(OPSession)
public class Session: NSObject {
    private var communicator: C2SCommunicator
    private var encryptor: Encryptor
    private var joseEncryptor: JOSEEncryptor
    private var stringFormatter: StringFormatter

    private var paymentProducts = BasicPaymentProducts()

    internal var clientSessionId: String {
        return communicator.clientSessionId
    }
    internal var paymentProductMapping = [AnyHashable: Any]()

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
        let configuration = C2SCommunicatorConfiguration(
            clientSessionId: clientSessionId,
            customerId: customerId,
            baseURL: baseURL,
            assetBaseURL: assetBaseURL,
            appIdentifier: appIdentifier,
            loggingEnabled: loggingEnabled,
            sdkIdentifier: sdkIdentifier
        )
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
        self.init(
            clientSessionId: clientSessionId,
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
        return Session.init(
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
        let strongSelf = self
        communicator.paymentProducts(
            forContext: context,
            success: { paymentProducts in
                strongSelf.paymentProducts = paymentProducts
                strongSelf.paymentProducts.stringFormatter = strongSelf.stringFormatter
                strongSelf.setLogoForPaymentItems(for: paymentProducts.paymentProducts) {
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

    @objc(paymentItemsForContext:success:failure:apiFailure:)
    public func paymentItems(
        for context: PaymentContext,
        success: ((_ paymentItems: PaymentItems) -> Void)? = nil,
        failure: ((_ error: Error) -> Void)? = nil,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        let strongSelf = self
        communicator.paymentProducts(
            forContext: context,
            success: { paymentProducts in
                if paymentProducts.paymentProducts.isEmpty {
                    success?(PaymentItems(products: paymentProducts, groups: nil))
                }

                strongSelf.paymentProducts = paymentProducts
                strongSelf.paymentProducts.stringFormatter = strongSelf.stringFormatter
                strongSelf.setLogoForPaymentItems(for: paymentProducts.paymentProducts) {
                    success?(PaymentItems(products: paymentProducts, groups: nil))
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
            return
        }

        let strongSelf = self
        communicator.paymentProduct(
            withIdentifier: paymentProductId,
            context: context,
            success: { paymentProduct in
                strongSelf.paymentProductMapping[key] = paymentProduct
                strongSelf.setLogoForDisplayHints(for: paymentProduct.displayHints) {
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

    @objc(IINDetailsForPartialCreditCardNumber:context:success:failure:apiFailure:)
    public func iinDetails(
        forPartialCreditCardNumber partialCreditCardNumber: String,
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
            let strongSelf = self
            communicator.paymentProductId(
                byPartialCreditCardNumber: partialCreditCardNumber,
                context: context,
                success: { response in
                    strongSelf.iinLookupPending = false
                    success?(response)
                },
                failure: { error in
                    strongSelf.iinLookupPending = false
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
            apiFailure: apiFailure
        )
    }

    @objc(preparePaymentRequest:success:failure:apiFailure:)
    public func prepare(
        _ paymentRequest: PaymentRequest,
        success: ((_ preparedPaymentRequest: PreparedPaymentRequest) -> Void)? = nil,
        failure: ((_ error: Error) -> Void)? = nil,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        let strongSelf = self
        self.publicKey(
            success: { publicKeyResponse in
                do {
                    let publicKeyAsData = publicKeyResponse.encodedPublicKey.decode()
                    let strippedPublicKeyAsData = try strongSelf.encryptor.stripPublicKey(data: publicKeyAsData)

                    let tag = "globalcollect-sdk-public-key-swift"

                    strongSelf.encryptor.deleteRSAKey(withTag: tag)
                    strongSelf.encryptor.storePublicKey(publicKey: strippedPublicKeyAsData, tag: tag)

                    guard let publicKey = strongSelf.encryptor.RSAKey(withTag: tag)
                    else {
                        failure?(EncryptDataError.rsaKeyNotFound)
                        return
                    }

                    let paymentRequestJSON =
                        strongSelf.preparePaymentRequestJSON(
                            forClientSessionId: strongSelf.clientSessionId,
                            paymentRequest: paymentRequest
                        )

                    let encryptedFields =
                        try strongSelf.joseEncryptor.encryptToCompactSerialization(
                            JSON: paymentRequestJSON,
                            withPublicKey: publicKey,
                            keyId: publicKeyResponse.keyId
                        )

                    let encodedClientMetaInfo = strongSelf.communicator.base64EncodedClientMetaInfo

                    let preparedRequest = PreparedPaymentRequest(
                        encryptedFields: encryptedFields,
                        encodedClientMetaInfo: encodedClientMetaInfo
                    )

                    success?(preparedRequest)
                } catch let error as EncryptorError {
                    failure?(error.asNSError)
                } catch {
                    failure?(error)
                }
            },
            failure: failure,
            apiFailure: apiFailure
        )
    }

    private func preparePaymentRequestJSON(
        forClientSessionId clientSessionId: String,
        paymentRequest: PaymentRequest
    ) -> String {
        guard let paymentProduct = paymentRequest.paymentProduct
        else {
            NSException(
                name: NSExceptionName(rawValue: "Invalid payment product"),
                reason: "Payment product is invalid"
            ).raise()
            // Return is mandatory but will never be reached because of the exception above.
            return "Invalid payment product"
        }

        var jsonDict: [String: Any] = [
            "clientSessionId": clientSessionId,
            "nonce": self.encryptor.generateUUID(),
        ]

        if let productId = Int(paymentProduct.identifier) {
            jsonDict["paymentProductId"] = productId
        }

        if let accountOnFile = paymentRequest.accountOnFile {
            jsonDict["accountOnFileId"] = accountOnFile.identifier
        }

        if paymentRequest.tokenize {
            jsonDict["tokenize"] = true
        }

        if let fieldVals = paymentRequest.unmaskedFieldValues {
            jsonDict["paymentValues"] = self.keyValuePairs(from: fieldVals)
        }

        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []),
            let jsonString = String(data: jsonData, encoding: .utf8)
        {
            return jsonString
        }

        NSException(
            name: NSExceptionName(rawValue: "JSON Serialization Error"),
            reason: "Failed to serialize JSON"
        ).raise()

        return "JSON Serialization Error"
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
            }
        )
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
        for (key, value) in dictionary {
            let pair = ["key": key, "value": value]
            keyValuePairs.append(pair)
        }

        return keyValuePairs
    }

    private func setLogoForPaymentItems(for paymentItems: [BasicPaymentItem], completion: @escaping () -> Void) {
        var counter = 0
        for paymentItem in paymentItems {
            if paymentItem.displayHints.isEmpty == false {
                setLogoForDisplayHints(
                    for: paymentItem.displayHints,
                    completion: {
                        counter += 1
                        if counter == paymentItems.count {
                            completion()
                        }
                    }
                )
            } else {
                counter += 1
                if counter == paymentItems.count {
                    completion()
                }
            }
        }
    }

    internal func setLogoForDisplayHints(
        for displayHints: [PaymentItemDisplayHints],
        completion: @escaping () -> Void
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

    internal func getLogoByStringURL(
        from url: String,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        guard let encodedUrlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            Logger.log("Unable to decode URL for url string: \(url)")
            completion(nil, nil, nil)
            return
        }

        guard let encodedUrl = URL(string: encodedUrlString) else {
            Logger.log("Unable to create URL for url string: \(encodedUrlString)")
            completion(nil, nil, nil)
            return
        }

        URLSession.shared.dataTask(
            with: encodedUrl,
            completionHandler: { data, response, error in
                DispatchQueue.main.async {
                    completion(data, response, error)
                }
            }
        ).resume()
    }
}
