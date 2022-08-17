//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020_
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Alamofire
import PassKit

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

    public var headers: HTTPHeaders {
        return [
            "Authorization": "GCS v1Client:\(clientSessionId)",
            "X-GCS-ClientMetaInfo": base64EncodedClientMetaInfo
        ]
    }

    @objc public init(configuration: C2SCommunicatorConfiguration) {
        self.configuration = configuration
    }

    @objc public func paymentProducts(forContext context: PaymentContext, success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void, failure: @escaping (_ error: Error) -> Void) {
        let isRecurring = context.isRecurring ? "true" : "false"
        let URL = "\(baseURL)/\(configuration.customerId)/products"
        var params: [String: Any] = ["countryCode": context.countryCode.rawValue, "currencyCode": context.amountOfMoney.currencyCode.rawValue, "amount": context.amountOfMoney.totalAmount, "hide": "fields", "isRecurring": isRecurring]

        if !context.locale.isEmpty {
            params["locale"] = context.locale
        }

        getResponse(forURL: URL, withParameters: params, success: { (responseObject) in
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
        }) { error in
            failure(error)
        }
    }

    @objc public func checkApplePayAvailability(with paymentProducts: BasicPaymentProducts,
                                          for context: PaymentContext,
                                          success: @escaping () -> Void,
                                          failure: @escaping (_ error: Error) -> Void) -> BasicPaymentProducts {
        if let applePayPaymentProduct = paymentProducts.paymentProduct(withIdentifier: SDKConstants.kApplePayIdentifier) {
            if SDKConstants.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: "8.0") && PKPaymentAuthorizationViewController.canMakePayments() {

                paymentProductNetworks(forProduct: SDKConstants.kApplePayIdentifier, context: context, success: {(_ paymentProductNetworks: PaymentProductNetworks) -> Void in
                    if let product = paymentProducts.paymentProducts.firstIndex(of: applePayPaymentProduct),
                        !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentProductNetworks.paymentProductNetworks) {
                        paymentProducts.paymentProducts.remove(at: product)
                    }
                    success()
                }, failure: { error in
                    failure(error)
                })
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
        if let googlePayPaymentProduct = paymentProducts.paymentProduct(withIdentifier: SDKConstants.kGooglePayIdentifier) {
            if let product = paymentProducts.paymentProducts.firstIndex(of: googlePayPaymentProduct) {
                paymentProducts.paymentProducts.remove(at: product)
            }
        }
        
        return paymentProducts
    }

    @objc public func paymentProductNetworks(forProduct paymentProductId: String,
                                       context: PaymentContext,
                                       success: @escaping (_ paymentProductNetworks: PaymentProductNetworks) -> Void,
                                       failure: @escaping (_ error: Error) -> Void) {
        let isRecurring = context.isRecurring ? "true" : "false"
        if context.locale.isEmpty {
            failure(SessionError.RuntimeError("Locale was nil."))
            return
        }
        let URL = "\(self.baseURL)/\(self.configuration.customerId)/products/\(paymentProductId)/networks"
        let params: [String: Any] = ["countryCode": context.countryCode.rawValue, "locale": context.locale, "currencyCode": context.amountOfMoney.currencyCode.rawValue, "amount": context.amountOfMoney.totalAmount, "hide": "fields", "isRecurring": isRecurring]

        getResponse(forURL: URL, withParameters: params, success: { (responseObject) in
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
        }) { error in
            failure(error)
        }
    }

    @objc public func paymentProduct(withIdentifier paymentProductId: String,
                               context: PaymentContext,
                               success: @escaping (_ paymentProduct: PaymentProduct) -> Void,
                               failure: @escaping (_ error: Error) -> Void) {

        checkAvailability(forProduct: paymentProductId, context: context, success: {() -> Void in
            let isRecurring = context.isRecurring ? "true" : "false"

            let URL = "\(self.baseURL)/\(self.configuration.customerId)/products/\(paymentProductId)/"
            var params: [String: Any] = ["countryCode": context.countryCode.rawValue, "currencyCode": context.amountOfMoney.currencyCode.rawValue, "amount": context.amountOfMoney.totalAmount, "isRecurring": isRecurring]
            params["forceBasicFlow"] = context.forceBasicFlow ? "true" : "false"
            if !context.locale.isEmpty {
                params["locale"] = context.locale
            }

            self.getResponse(forURL: URL, withParameters: params, success: { (responseObject) in
                guard let responseDic = responseObject as? [String: Any], let paymentProduct = PaymentProduct(json: responseDic) else {
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

            if fieldId == CARD_NUMBER_FIELD_ID && (paymentProductField.displayHints.mask == nil || paymentProductField.displayHints.mask!.isEmpty) {
                if paymentProduct.identifier == AMEX_PRODUCT_ID {
                    paymentProductField.displayHints.mask = AMEX_CARD_NUMBER_MASK
                } else {
                    paymentProductField.displayHints.mask = REGULAR_CARD_NUMBER_MASK
                }
            }
        }
    }

    @objc public func checkAvailability(forProduct paymentProductId: String, context: PaymentContext, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        if paymentProductId == SDKConstants.kApplePayIdentifier {
            if SDKConstants.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: "8.0") && PKPaymentAuthorizationViewController.canMakePayments() {
                paymentProductNetworks(forProduct: SDKConstants.kApplePayIdentifier, context: context, success: {(_ paymentProductNetworks: PaymentProductNetworks) -> Void in
                    if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentProductNetworks.paymentProductNetworks) {
                        failure(self.badRequestError(forProduct: paymentProductId, context: context))
                    } else {
                        success()
                    }
                }, failure: { error in
                    failure(error)
                })
            } else {
                failure(badRequestError(forProduct: paymentProductId, context: context))
            }
        } else {
            success()
        }
    }

    @objc public func badRequestError(forProduct paymentProductId: String, context: PaymentContext) -> Error {
        let isRecurring = context.isRecurring ? "true" : "false"
        let url = "\(baseURL)/\(configuration.customerId)/products/\(paymentProductId)/?countryCode=\(context.countryCode.rawValue)&locale=\(context.locale)&currencyCode=\(context.amountOfMoney.currencyCode.rawValue)&amount=\(UInt(context.amountOfMoney.totalAmount))&isRecurring=\(isRecurring)"
        let errorUserInfo = ["com.alamofire.serialization.response.error.response":
            HTTPURLResponse(url: URL(string: url)!, statusCode: 400, httpVersion: nil, headerFields: ["Connection": "close"])!, "NSErrorFailingURLKey": url, "com.alamofire.serialization.response.error.data": Data(), "NSLocalizedDescription": "Request failed: bad request (400)"] as [String: Any]
        let error = NSError(domain: "com.alamofire.serialization.response.error.response", code: -1011, userInfo: errorUserInfo)
        return error
    }

    @objc public func publicKey(success: @escaping (_ publicKeyResponse: PublicKeyResponse) -> Void, failure: @escaping (_ error: Error) -> Void) {
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

    @objc public func paymentProductId(byPartialCreditCardNumber partialCreditCardNumber: String,
                                 context: PaymentContext?,
                                 success: @escaping (_ iinDetailsResponse: IINDetailsResponse) -> Void,
                                 failure: @escaping (_ error: Error) -> Void) {
        let URL = "\(baseURL)/\(configuration.customerId)/services/getIINdetails"

        var parameters: [String: Any] = [:]
        parameters["bin"] = getIINDigitsFrom(partialCreditCardNumber: partialCreditCardNumber)

        if let context = context {
            var paymentContext: [String: Any] = [:]
            paymentContext["isRecurring"] = context.isRecurring ? "true" : "false"
            paymentContext["countryCode"] = context.countryCode.rawValue

            var amountOfMoney: [String: Any] = [:]
            amountOfMoney["amount"] = String(context.amountOfMoney.totalAmount)
            amountOfMoney["currencyCode"] = context.amountOfMoney.currencyCode.rawValue
            paymentContext["amountOfMoney"] = amountOfMoney

            parameters["paymentContext"] = paymentContext
        }

        let additionalAcceptableStatusCodes = IndexSet(integer: 404)
        postResponse(forURL: URL, withParameters: parameters, additionalAcceptableStatusCodes: additionalAcceptableStatusCodes, success: {(responseObject) -> Void in
            guard let json = responseObject as? [String: Any] else {
                failure(SessionError.RuntimeError("Response was not a dictionary. Raw response: \(responseObject)"))
                return
            }
            let response = IINDetailsResponse(json: json)
            success(response)
        }, failure: { error in
            failure(error)
        })
    }

    internal func getIINDigitsFrom(partialCreditCardNumber: String) -> String {
        let max: Int
        if partialCreditCardNumber.count >= 8 {
            max = 8
        } else {
            max = min(partialCreditCardNumber.count, 6)
        }
        return String(partialCreditCardNumber[..<partialCreditCardNumber.index(partialCreditCardNumber.startIndex, offsetBy: max)])
    }

    @objc public func getResponse(forURL URL: String, withParameters parameters: Parameters? = nil, success: @escaping (_ responseObject: Any) -> Void, failure: @escaping (_ error: Error) -> Void) {
        networkingWrapper.getResponse(forURL: URL, withParameters: parameters, headers: headers, additionalAcceptableStatusCodes: nil, success: success, failure: failure)
    }

    @objc public func postResponse(forURL URL: String, withParameters parameters: [AnyHashable: Any], additionalAcceptableStatusCodes: IndexSet, success: @escaping (_ responseObject: Any) -> Void, failure: @escaping (_ error: Error) -> Void) {
        networkingWrapper.postResponse(forURL: URL, headers: headers, withParameters: parameters as? Parameters, additionalAcceptableStatusCodes: additionalAcceptableStatusCodes, success: success, failure: failure)
    }

}
