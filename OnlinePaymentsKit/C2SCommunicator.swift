//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020_
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Alamofire
import PassKit

internal class C2SCommunicator {
    var configuration: C2SCommunicatorConfiguration
    var networkingWrapper = AlamofireWrapper.shared

    var clientSessionId: String {
        return configuration.clientSessionId
    }

    var base64EncodedClientMetaInfo: String {
        return configuration.base64EncodedClientMetaInfo ?? ""
    }

    var loggingEnabled: Bool {
        return configuration.loggingEnabled
    }

    var headers: HTTPHeaders {
        return [
            "Authorization": "GCS v1Client:\(clientSessionId)",
            "X-GCS-ClientMetaInfo": base64EncodedClientMetaInfo
        ]
    }

    init(configuration: C2SCommunicatorConfiguration) {
        self.configuration = configuration
    }

    func paymentProducts(
        forContext context: PaymentContext,
        success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        let url = getApiUrl(path: "/products")
        let params = buildParameters(for: context)

        let strongSelf = self;
        getResponse(
            forURL: url,
            withParameters: params,
            success: { (responseObject: BasicPaymentProducts?) in
                guard let paymentProductsResponse = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                strongSelf.checkApplePayAvailability(
                    with: paymentProductsResponse,
                    for: context,
                    success: { products in
                        success(products)
                    }, failure: { error in
                        failure(error)
                    }, apiFailure: { errorResponse in
                        apiFailure?(errorResponse)
                    }
                )
            },
            failure: failure,
            apiFailure: apiFailure
        )
    }

    func checkApplePayAvailability(
        with paymentProducts: BasicPaymentProducts,
        for context: PaymentContext,
        success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        if let applePayPaymentProduct = paymentProducts.paymentProduct(withIdentifier: SDKConstants.kApplePayIdentifier) {

            if SDKConstants.systemVersionGreaterThanOrEqualTo("8.0") && PKPaymentAuthorizationViewController.canMakePayments() {
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
                        success(paymentProducts)
                    },
                    failure: failure,
                    apiFailure: apiFailure
                )
            } else {
                if let product = paymentProducts.paymentProducts.firstIndex(of: applePayPaymentProduct) {
                    paymentProducts.paymentProducts.remove(at: product)
                }

                success(paymentProducts)
            }
        } else {
            success(paymentProducts)
        }
    }

    func paymentProductNetworks(
        forProduct paymentProductId: String,
        context: PaymentContext,
        success: @escaping (_ paymentProductNetworks: PaymentProductNetworks) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        if context.locale.isEmpty {
            failure(SessionError.RuntimeError("Locale was nil."))
            return
        }

        let URL = getApiUrl(path: "/products/\(paymentProductId)/networks")

        var params = buildParameters(for: context)
        params["hide"] = "fields"

        getResponse(
            forURL: URL,
            withParameters: params,
            success: { (responseObject: PaymentProductNetworks?) in
                guard let productNetworksResponse = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                success(productNetworksResponse)
            },
            failure: failure,
            apiFailure: apiFailure
        )
    }

    func paymentProduct(
        withIdentifier paymentProductId: String,
        context: PaymentContext,
        success: @escaping (_ paymentProduct: PaymentProduct) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        let strongSelf = self;
        checkAvailability(
            forProduct: paymentProductId,
            context: context,
            success: {() -> Void in
                let URL = strongSelf.getApiUrl(path: "/products/\(paymentProductId)/")
                let params = strongSelf.buildParameters(for: context)

                strongSelf.getResponse(
                    forURL: URL,
                    withParameters: params,
                    success: { (responseObject: PaymentProduct?) in
                        guard let paymentProductResponse = responseObject else {
                            failure(SessionError.RuntimeError("Response was empty."))
                            return
                        }

                        strongSelf.fixProductParametersIfRequired(forProduct: paymentProductResponse)

                        success(paymentProductResponse)
                    },
                    failure: failure,
                    apiFailure: apiFailure
                )
            },
            failure: failure,
            apiFailure: apiFailure
        )
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

    func checkAvailability(
        forProduct paymentProductId: String,
        context: PaymentContext,
        success: @escaping () -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        if paymentProductId == SDKConstants.kApplePayIdentifier {
            if SDKConstants.systemVersionGreaterThanOrEqualTo("8.0") &&
                PKPaymentAuthorizationViewController.canMakePayments() {
                let strongSelf = self;
                paymentProductNetworks(
                    forProduct: SDKConstants.kApplePayIdentifier,
                    context: context,
                    success: {(_ paymentProductNetworks: PaymentProductNetworks) -> Void in
                        if !PKPaymentAuthorizationViewController.canMakePayments(
                            usingNetworks: paymentProductNetworks.paymentProductNetworks
                        ) {
                            failure(strongSelf.badRequestError(forProduct: paymentProductId, context: context))
                        } else {
                            success()
                        }
                    },
                    failure: failure,
                    apiFailure: apiFailure
                )
            } else {
                failure(badRequestError(forProduct: paymentProductId, context: context))
            }
        } else {
            success()
        }
    }

    func badRequestError(forProduct paymentProductId: String, context: PaymentContext) -> Error {
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
        let urlParameters = buildParameters(for: context)
            .map { key, value in
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let encodedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "\(value)"

                return "\(encodedKey)=\(encodedValue)"
            }.joined(separator: "&")

        return getApiUrl(path: "/products/\(paymentProductId)?\(urlParameters)")
    }

    func publicKey(
        success: @escaping (_ publicKeyResponse: PublicKeyResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        let URL = getApiUrl(path: "/crypto/publickey")
        getResponse(
            forURL: URL,
            success: {(_ responseObject: PublicKeyResponse?) -> Void in
                guard let publicKeyResponse = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                success(publicKeyResponse)
            },
            failure: failure,
            apiFailure: apiFailure
        )
    }

    func paymentProductId(
        byPartialCreditCardNumber partialCreditCardNumber: String,
        context: PaymentContext?,
        success: @escaping (_ iinDetailsResponse: IINDetailsResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        let URL = getApiUrl(path: "/services/getIINdetails")

        var parameters: [String: Any] = [
            "bin": getIINDigitsFrom(partialCreditCardNumber: partialCreditCardNumber)
        ]

        if let context = context {
            parameters["paymentContext"] = [
                "isRecurring": context.isRecurring ? "true" : "false",
                "countryCode": context.countryCode,
                "amountOfMoney": [
                    "amount": String(context.amountOfMoney.totalAmount),
                    "currencyCode": context.amountOfMoney.currencyCode
                ]
            ]
        }

        let additionalAcceptableStatusCodes = IndexSet(integer: 404)
        postResponse(
            forURL: URL,
            withParameters: parameters,
            additionalAcceptableStatusCodes: additionalAcceptableStatusCodes,
            success: {(responseObject: IINDetailsResponse?) -> Void in
                guard let iinDetailsResponse = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                success(iinDetailsResponse)
            },
            failure: failure,
            apiFailure: apiFailure
        )
    }

    func getIINDigitsFrom(partialCreditCardNumber: String) -> String {
        let max: Int
        if partialCreditCardNumber.count >= 8 {
            max = 8
        } else {
            max = min(partialCreditCardNumber.count, 6)
        }

        return String(
            partialCreditCardNumber[
                ..<partialCreditCardNumber.index(partialCreditCardNumber.startIndex, offsetBy: max)
            ]
        )
    }

    internal func currencyConversionQuote(
        amountOfMoney: AmountOfMoney,
        cardSource: CardSource,
        success: @escaping (_ currencyConversionResponse: CurrencyConversionResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        let URL = getApiUrl(path: "/services/dccrate")

        let parameters: [String: Any] = [
            "cardSource": getCardSourceParameter(cardSource: cardSource),
            "transaction": [
                "amount": getAmountOfMoneyParameter(amountOfMoney: amountOfMoney)
            ]
        ]

        postResponse(
            forURL: URL,
            withParameters: parameters,
            additionalAcceptableStatusCodes: nil,
            success: {(responseObject: CurrencyConversionResponse?) -> Void in
                guard let currencyConversionResponse = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                success(currencyConversionResponse)
            },
            failure: failure,
            apiFailure: apiFailure
        )
    }

    func surchargeCalculation(
        amountOfMoney: AmountOfMoney,
        cardSource: CardSource,
        success: @escaping (_ surchargeCalculationResponse: SurchargeCalculationResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        let URL = getApiUrl(path: "/services/surchargecalculation")

        let parameters: [String: Any] = [
            "amountOfMoney": getAmountOfMoneyParameter(amountOfMoney: amountOfMoney),
            "cardSource": getCardSourceParameter(cardSource: cardSource)
        ]

        postResponse(
            forURL: URL,
            withParameters: parameters,
            additionalAcceptableStatusCodes: nil,
            success: {(responseObject: SurchargeCalculationResponse?) -> Void in
                guard let surchargeCalculationResponse = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                success(surchargeCalculationResponse)
            },
            failure: { error in
                failure(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    private func getCardSourceParameter(cardSource: CardSource) -> [String: Any] {
        return [
            "card": cardSource.card.flatMap { card in
                    var cardDict: [String: Any] = [
                        "cardNumber": card.cardNumber
                    ]

                    if let paymentProductId = card.paymentProductId {
                        cardDict["paymentProductId"] = paymentProductId
                    }

                    return cardDict
                },
            "token": cardSource.token
        ].compactMapValues { $0 }
    }

    private func getAmountOfMoneyParameter(amountOfMoney: AmountOfMoney) -> [String: Any] {
        return [
            "amount": amountOfMoney.totalAmount,
            "currencyCode": amountOfMoney.totalAmount
        ]
    }

    private func getResponse<T: Codable>(
        forURL URL: String,
        withParameters parameters: Parameters? = nil,
        success: @escaping (_ responseObject: T?) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        if loggingEnabled {
            logRequest(forURL: URL, requestMethod: .get)
        }

        let strongSelf = self;

        let successHandler: (T?, Int?) -> Void = { (responseObject, statusCode) -> Void in
            if strongSelf.loggingEnabled {
                strongSelf.logSuccessResponse(forURL: URL, withResponseCode: statusCode, forResponse: responseObject)
            }

            success(responseObject)
        }

        networkingWrapper.getResponse(
            forURL: URL,
            headers: headers,
            withParameters: parameters,
            additionalAcceptableStatusCodes: nil,
            success: successHandler,
            failure: { error in
                if strongSelf.loggingEnabled {
                    strongSelf.logFailureResponse(forURL: URL, forError: error)
                }

                failure(error)
            },
            apiFailure: { errorResponse in
                if strongSelf.loggingEnabled {
                    strongSelf.logApiFailureResponse(forURL: URL, forApiError: errorResponse)
                }

                apiFailure?(errorResponse)
            }
        )
    }

    private func postResponse<T: Codable>(
        forURL URL: String,
        withParameters parameters: [AnyHashable: Any],
        additionalAcceptableStatusCodes: IndexSet?,
        success: @escaping (_ responseObject: T?) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil
    ) {
        if loggingEnabled {
            logRequest(forURL: URL, requestMethod: .post, postBody: parameters as? Parameters)
        }

        let strongSelf = self;
        let successHandler: (T?, Int?) -> Void = { (responseObject, statusCode) -> Void in
            if strongSelf.loggingEnabled {
                strongSelf.logSuccessResponse(forURL: URL, withResponseCode: statusCode, forResponse: responseObject)
            }

            success(responseObject)
        }

        networkingWrapper.postResponse(
            forURL: URL,
            headers: headers,
            withParameters: parameters as? Parameters,
            additionalAcceptableStatusCodes: additionalAcceptableStatusCodes,
            success: successHandler,
            failure: { error in
                if strongSelf.loggingEnabled {
                    strongSelf.logFailureResponse(forURL: URL, forError: error)
                }

                failure(error)
            },
            apiFailure: { errorResponse in
                if strongSelf.loggingEnabled {
                    strongSelf.logApiFailureResponse(forURL: URL, forApiError: errorResponse)
                }

                apiFailure?(errorResponse)
            }
        )
    }

    private func logSuccessResponse<T: Codable>(
        forURL URL: String,
        withResponseCode responseCode: Int?,
        forResponse response: T
    ) {
        guard let responseData = try? JSONEncoder().encode(response) else {
            print("Success response received, but could not be encoded.")
            return
        }

        let responseString = String(decoding: responseData, as: UTF8.self)
        self.logResponse(forURL: URL, responseCode: responseCode, responseBody: responseString)
    }

    private func logFailureResponse(forURL URL: String, forError error: Error) {
        self.logResponse(
            forURL: URL,
            responseCode: error.asAFError?.responseCode,
            responseBody: "\(error.localizedDescription)",
            isError: true
        )
    }

    private func logApiFailureResponse(forURL URL: String, forApiError errorResponse: ErrorResponse) {
        self.logResponse(
            forURL: URL,
            responseCode: nil,
            responseBody: errorResponse.message,
            isApiError: true
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
    private func logResponse(
        forURL URL: String,
        responseCode: Int?,
        responseBody: String,
        isError: Bool = false,
        isApiError: Bool = false
    ) {
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

        if isApiError {
            responseLog += "API Error : "
        } else if isError {
            responseLog += "Response Error : "
        } else {
            responseLog += "Response Body : "
        }

        responseLog += responseBody

        print(responseLog)
    }

    private func getApiUrl(path: String, queryParameters: String? = nil) -> String {
        var url = "\(configuration.customerId)\(path)"
        if let queryParameters = queryParameters {
            url += "?\(queryParameters)"
        }

        return configuration.getUrl(version: .v1, apiUrl: url)
    }

    private func buildParameters(for context: PaymentContext) -> [String: Any] {
        var params: [String: Any] =
        [
            "countryCode": context.countryCode,
            "currencyCode": context.amountOfMoney.currencyCode,
            "amount": context.amountOfMoney.totalAmount,
            "isRecurring": context.isRecurring ? "true" : "false"
        ]

        if !context.locale.isEmpty {
            params["locale"] = context.locale
        }

        return params
    }
}
