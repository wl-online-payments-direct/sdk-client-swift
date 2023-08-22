//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020_
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Alamofire
import PassKit

@available(
    *,
    deprecated,
    message:
        """
        In a future release, this class, its functions and its properties will become internal to the SDK.
        """
)
@objc(OPC2SCommunicator)
public class C2SCommunicator: NSObject {
    @objc public var configuration: C2SCommunicatorConfiguration
    @objc public var networkingWrapper = AlamofireWrapper.shared

    @objc public var baseURL: String {
        return configuration.baseURL
    }

    @objc public var assetsBaseURL: String {
        return configuration.assetsBaseURL
    }

    @objc public var clientSessionId: String {
        return configuration.clientSessionId
    }

    @objc public var base64EncodedClientMetaInfo: String {
        return configuration.base64EncodedClientMetaInfo ?? ""
    }

    internal var loggingEnabled: Bool {
        return configuration.loggingEnabled
    }

    public var headers: HTTPHeaders {
        return [
            "Authorization": "GCS v1Client:\(clientSessionId)",
            "X-GCS-ClientMetaInfo": base64EncodedClientMetaInfo
        ]
    }

    @objc public init(configuration: C2SCommunicatorConfiguration) {
        self.configuration = configuration
    }

    @objc public func paymentProducts(
        forContext context: PaymentContext,
        success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        let isRecurring = context.isRecurring ? "true" : "false"
        let URL = "\(baseURL)/\(configuration.customerId)/products"
        var params: [String: Any] =
            [
                "countryCode": context.countryCodeString,
                "currencyCode": context.amountOfMoney.currencyCodeString,
                "amount": context.amountOfMoney.totalAmount, "hide": "fields",
                "isRecurring": isRecurring
            ]

        if !context.locale.isEmpty {
            params["locale"] = context.locale
        }

        getResponse(
            forURL: URL,
            withParameters: params,
            success: { (responseObject) in
                guard let responseDic = responseObject as? [String: Any] else {
                    failure(SessionError.RuntimeError("Response was not a dictionary. Raw response: \(responseObject)"))
                    return
                }
                var paymentProducts = BasicPaymentProducts(json: responseDic)

                paymentProducts = self.checkApplePayAvailability(with: paymentProducts, for: context, success: {
                    success(paymentProducts)
                }, failure: { error in
                    failure(error)
                })
                paymentProducts = self.removeGooglePayProduct(with: paymentProducts)
            },
            failure: { error in
                failure(error)
            }
        )
    }

    @objc(checkApplePayAvailabilityWithPaymentProducts:forContext:success:failure:)
    public func checkApplePayAvailability(
        with paymentProducts: BasicPaymentProducts,
        for context: PaymentContext,
        success: @escaping () -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) -> BasicPaymentProducts {
        if let applePayPaymentProduct =
            paymentProducts.paymentProduct(withIdentifier: SDKConstants.kApplePayIdentifier) {
            if SDKConstants.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: "8.0") &&
                PKPaymentAuthorizationViewController.canMakePayments() {
                paymentProductNetworks(
                    forProduct: SDKConstants.kApplePayIdentifier,
                    context: context,
                    success: {(_ paymentProductNetworks: PaymentProductNetworks) -> Void in
                        if let product = paymentProducts.paymentProducts.firstIndex(of: applePayPaymentProduct),
                            !PKPaymentAuthorizationViewController.canMakePayments(
                                usingNetworks: paymentProductNetworks.paymentProductNetworks
                            ) {
                            paymentProducts.paymentProducts.remove(at: product)
                        }
                        success()
                    },
                    failure: { error in
                        failure(error)
                    }
                )
            } else {
                if let product = paymentProducts.paymentProducts.firstIndex(of: applePayPaymentProduct) {
                    paymentProducts.paymentProducts.remove(at: product)
                }

                success()
            }
        } else {
            success()
        }

        return paymentProducts
    }

    private func removeGooglePayProduct(with paymentProducts: BasicPaymentProducts) -> BasicPaymentProducts {
        if let googlePayPaymentProduct =
                paymentProducts.paymentProduct(withIdentifier: SDKConstants.kGooglePayIdentifier) {
            if let product = paymentProducts.paymentProducts.firstIndex(of: googlePayPaymentProduct) {
                paymentProducts.paymentProducts.remove(at: product)
            }
        }

        return paymentProducts
    }

    @objc(paymentProductNetworksForProductId:context:success:failure:)
    public func paymentProductNetworks(
        forProduct paymentProductId: String,
        context: PaymentContext,
        success: @escaping (_ paymentProductNetworks: PaymentProductNetworks) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        let isRecurring = context.isRecurring ? "true" : "false"
        if context.locale.isEmpty {
            failure(SessionError.RuntimeError("Locale was nil."))
            return
        }
        let URL = "\(self.baseURL)/\(self.configuration.customerId)/products/\(paymentProductId)/networks"
        let params: [String: Any] =
        [
            "countryCode": context.countryCodeString,
            "locale": context.locale,
            "currencyCode": context.amountOfMoney.currencyCodeString,
            "amount": context.amountOfMoney.totalAmount,
            "hide": "fields",
            "isRecurring": isRecurring
        ]

        getResponse(
            forURL: URL,
            withParameters: params,
            success: { (responseObject) in
                guard let response = responseObject as? [String: Any] else {
                    failure(SessionError.RuntimeError("Response was not a dictionary. Raw response: \(responseObject)"))
                    return
                }
                let rawProductNetworks = response["networks"]
                let paymentProductNetworks = PaymentProductNetworks()
                if let productNetworks = rawProductNetworks as? [PKPaymentNetwork] {
                    paymentProductNetworks.paymentProductNetworks.append(contentsOf: productNetworks)
                }
                success(paymentProductNetworks)
            },
            failure: { error in
                failure(error)
            }
        )
    }

    @objc(paymentProductWithId:context:success:failure:)
    public func paymentProduct(
        withIdentifier paymentProductId: String,
        context: PaymentContext,
        success: @escaping (_ paymentProduct: PaymentProduct) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        checkAvailability(forProduct: paymentProductId, context: context, success: {() -> Void in
            let isRecurring = context.isRecurring ? "true" : "false"

            let URL = "\(self.baseURL)/\(self.configuration.customerId)/products/\(paymentProductId)/"
            var params: [String: Any] =
            [
                "countryCode": context.countryCodeString,
                "currencyCode": context.amountOfMoney.currencyCodeString,
                "amount": context.amountOfMoney.totalAmount,
                "isRecurring": isRecurring
            ]

            if !context.locale.isEmpty {
                params["locale"] = context.locale
            }

            self.getResponse(forURL: URL, withParameters: params, success: { (responseObject) in
                guard let responseDic = responseObject as? [String: Any],
                      let paymentProduct = PaymentProduct(json: responseDic) else {
                    failure(SessionError.RuntimeError("Response was not a dictionary. Raw response: \(responseObject)"))
                    return
                }

                self.fixProductParametersIfRequired(forProduct: paymentProduct)

                success(paymentProduct)
            }, failure: { error in
                failure(error)
            })
        }, failure: { error in
            failure(error)
        })
    }

    private func fixProductParametersIfRequired(forProduct paymentProduct: PaymentItem) {
        let EXPIRY_DATE_MASK = "{{99}}/{{99}}"
        let REGULAR_CARD_NUMBER_MASK = "{{9999}} {{9999}} {{9999}} {{9999}}"
        let AMEX_CARD_NUMBER_MASK = "{{9999}} {{999999}} {{99999}}"
        let AMEX_PRODUCT_ID = "2"
        let EXPIRY_DATE_FIELD_ID = "expiryDate"
        let CARD_NUMBER_FIELD_ID = "cardNumber"

        for paymentProductField in paymentProduct.fields.paymentProductFields {
            let fieldId = paymentProductField.identifier
            if fieldId != EXPIRY_DATE_FIELD_ID && fieldId != CARD_NUMBER_FIELD_ID {
                continue
            }

            if fieldId == EXPIRY_DATE_FIELD_ID {
                // Fix the field type
                if paymentProductField.displayHints.formElement.type == .listType {
                    paymentProductField.displayHints.formElement.type = .textType
                }

                // Add te field mask
                if paymentProductField.displayHints.mask == nil || paymentProductField.displayHints.mask!.isEmpty {
                    paymentProductField.displayHints.mask = EXPIRY_DATE_MASK
                }
            }

            if fieldId ==
                CARD_NUMBER_FIELD_ID &&
                (paymentProductField.displayHints.mask == nil || paymentProductField.displayHints.mask!.isEmpty) {
                if paymentProduct.identifier == AMEX_PRODUCT_ID {
                    paymentProductField.displayHints.mask = AMEX_CARD_NUMBER_MASK
                } else {
                    paymentProductField.displayHints.mask = REGULAR_CARD_NUMBER_MASK
                }
            }
        }
    }

    @objc(checkAvailabilityForPaymentProductWithId:context:success:failure:)
    public func checkAvailability(
        forProduct paymentProductId: String,
        context: PaymentContext,
        success: @escaping () -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        if paymentProductId == SDKConstants.kApplePayIdentifier {
            if SDKConstants.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: "8.0") &&
                PKPaymentAuthorizationViewController.canMakePayments() {
                paymentProductNetworks(
                    forProduct: SDKConstants.kApplePayIdentifier,
                    context: context,
                    success: {(_ paymentProductNetworks: PaymentProductNetworks) -> Void in
                        if !PKPaymentAuthorizationViewController.canMakePayments(
                            usingNetworks: paymentProductNetworks.paymentProductNetworks
                        ) {
                            failure(self.badRequestError(forProduct: paymentProductId, context: context))
                        } else {
                            success()
                        }
                    },
                    failure: { error in
                        failure(error)
                    }
                )
            } else {
                failure(badRequestError(forProduct: paymentProductId, context: context))
            }
        } else {
            success()
        }
    }

    @objc(badRequestErrorForPaymentProductId:context:)
    public func badRequestError(forProduct paymentProductId: String, context: PaymentContext) -> Error {
        let url = createBadRequestErrorURL(forProduct: paymentProductId, context: context)
        let errorUserInfo =
        [
            "com.alamofire.serialization.response.error.response":
            HTTPURLResponse(
                url: URL(string: url)!,
                statusCode: 400,
                httpVersion: nil,
                headerFields: ["Connection": "close"]
            )!,
            "NSErrorFailingURLKey": url,
            "com.alamofire.serialization.response.error.data": Data(),
            "NSLocalizedDescription": "Request failed: bad request (400)"
        ] as [String: Any]
        let error =
            NSError(
                domain: "com.alamofire.serialization.response.error.response",
                code: -1011,
                userInfo: errorUserInfo
            )
        return error
    }

    private func createBadRequestErrorURL(forProduct paymentProductId: String, context: PaymentContext) -> String {
        let isRecurring = context.isRecurring ? "true" : "false"
        // swiftlint:disable line_length
        return
            "\(baseURL)/\(configuration.customerId)/products/\(paymentProductId)/?countryCode=\(context.countryCodeString)&locale=\(context.locale)&currencyCode=\(context.amountOfMoney.currencyCodeString)&amount=\(UInt(context.amountOfMoney.totalAmount))&isRecurring=\(isRecurring)"
        // swiftlint:enable line_length
    }

    @objc(publicKeyWithSuccess:failure:)
    public func publicKey(
        success: @escaping (_ publicKeyResponse: PublicKeyResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        let URL = "\(baseURL)/\(configuration.customerId)/crypto/publickey"
        getResponse(forURL: URL, success: {(_ responseObject: Any) -> Void in
            guard let rawPublicKeyResponse = responseObject as? [AnyHashable: Any],
                let keyId = rawPublicKeyResponse["keyId"] as? String,
                let encodedPublicKey = rawPublicKeyResponse["publicKey"] as? String else {
                    failure(SessionError.RuntimeError("Response was invalid. Raw response: \(responseObject)"))
                    return
            }
            let response = PublicKeyResponse(keyId: keyId, encodedPublicKey: encodedPublicKey)
            success(response)
        }, failure: { error in
            failure(error)
        })
    }

    @objc public func paymentProductId(
        byPartialCreditCardNumber partialCreditCardNumber: String,
        context: PaymentContext?,
        success: @escaping (_ iinDetailsResponse: IINDetailsResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        let URL = "\(baseURL)/\(configuration.customerId)/services/getIINdetails"

        var parameters: [String: Any] = [:]
        parameters["bin"] = getIINDigitsFrom(partialCreditCardNumber: partialCreditCardNumber)

        if let context = context {
            var paymentContext: [String: Any] = [:]
            paymentContext["isRecurring"] = context.isRecurring ? "true" : "false"
            paymentContext["countryCode"] = context.countryCodeString

            var amountOfMoney: [String: Any] = [:]
            amountOfMoney["amount"] = String(context.amountOfMoney.totalAmount)
            amountOfMoney["currencyCode"] = context.amountOfMoney.currencyCodeString
            paymentContext["amountOfMoney"] = amountOfMoney

            parameters["paymentContext"] = paymentContext
        }

        let additionalAcceptableStatusCodes = IndexSet(integer: 404)
        postResponse(
            forURL: URL,
            withParameters: parameters,
            additionalAcceptableStatusCodes: additionalAcceptableStatusCodes,
            success: {(responseObject) -> Void in
                guard let json = responseObject as? [String: Any] else {
                    failure(SessionError.RuntimeError("Response was not a dictionary. Raw response: \(responseObject)"))
                    return
                }
                let response = IINDetailsResponse(json: json)
                success(response)
            },
            failure: { error in
                failure(error)
            }
        )
    }

    internal func getIINDigitsFrom(partialCreditCardNumber: String) -> String {
        let max: Int
        if partialCreditCardNumber.count >= 8 {
            max = 8
        } else {
            max = min(partialCreditCardNumber.count, 6)
        }
        return
            String(
                partialCreditCardNumber[
                    ..<partialCreditCardNumber.index(partialCreditCardNumber.startIndex, offsetBy: max)
                ]
            )
    }

    @objc public func getResponse(
        forURL URL: String,
        withParameters parameters: Parameters? = nil,
        success: @escaping (_ responseObject: Any) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        if loggingEnabled {
            logRequest(forURL: URL, requestMethod: .get)
        }

        networkingWrapper.getResponse(
            forURL: URL,
            withParameters: parameters,
            headers: headers,
            additionalAcceptableStatusCodes: nil,
            success: { response in
                if self.loggingEnabled {
                    self.logSuccessResponse(forURL: URL, forResponse: response)
                }
                success(response as Any)
            },
            failure: { error in
                if self.loggingEnabled {
                    self.logFailureResponse(forURL: URL, forError: error)
                }
                failure(error)
            }
        )
    }

    @objc public func postResponse(
        forURL URL: String,
        withParameters parameters: [AnyHashable: Any],
        additionalAcceptableStatusCodes: IndexSet,
        success: @escaping (_ responseObject: Any) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        if loggingEnabled {
            logRequest(forURL: URL, requestMethod: .post, postBody: parameters as? Parameters)
        }

        networkingWrapper.postResponse(
            forURL: URL,
            headers: headers,
            withParameters: parameters as? Parameters,
            additionalAcceptableStatusCodes: additionalAcceptableStatusCodes,
            success: { response in
                if self.loggingEnabled {
                    self.logSuccessResponse(forURL: URL, forResponse: response)
                }
                success(response as Any)
            },
            failure: { error in
                if self.loggingEnabled {
                    self.logFailureResponse(forURL: URL, forError: error)
                }
                failure(error)
            }
        )
    }

    private func responseWithoutStatusCode(response: [String: Any]?) -> [String: Any]? {
        var originalResponse = response
        originalResponse?.removeValue(forKey: "statusCode")

        return originalResponse
    }

    private func logSuccessResponse(forURL URL: String, forResponse response: [String: Any]?) {
        let responseCode = response?["statusCode"] as? Int

        let originalResponse = self.responseWithoutStatusCode(response: response)

        self.logResponse(forURL: URL, responseCode: responseCode, responseBody: "\(originalResponse as AnyObject)")
    }

    private func logFailureResponse(forURL URL: String, forError error: Error) {
        self.logResponse(
            forURL: URL,
            responseCode: error.asAFError?.responseCode,
            responseBody: "\(error.localizedDescription)",
            isError: true
        )
    }

    /**
     * Logs all request headers, url and body
     */
    private func logRequest(forURL URL: String, requestMethod: HTTPMethod, postBody: Parameters? = nil) {
        var requestLog =
        """
        Request URL : \(URL)
        Request Method : \(requestMethod.rawValue)
        Request Headers : \n
        """

        headers.forEach { header in
            requestLog += " \(header) \n"
        }

        if requestMethod == .post {
            requestLog += "Body: \(postBody?.description ?? "")"
        }

        print(requestLog)
    }

    /**
     * Logs all response headers, status code and body
     */
    private func logResponse(forURL URL: String, responseCode: Int?, responseBody: String, isError: Bool = false) {
        var responseLog =
        """
        Response URL : \(URL)
        Response Code :
        """

        if let responseCode {
            responseLog += " \(responseCode) \n"
        } else {
            responseLog += " Nil \n"
        }

        responseLog += "Response Headers : \n"

        headers.forEach { header in
            responseLog += " \(header) \n"
        }

        responseLog += isError ? "Response Error : " : "Response Body : "
        responseLog += responseBody

        print(responseLog)
    }
}
