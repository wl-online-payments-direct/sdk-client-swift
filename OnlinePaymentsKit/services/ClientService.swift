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

internal class ClientService: ClientServiceProtocol {

    private let apiClient: ApiClientProtocol
    private let cacheManager: CacheManagerProtocol
    private let sessionData: SessionData

    internal var iinLookupPending = false

    internal init(
        apiClient: ApiClientProtocol,
        cacheManager: CacheManagerProtocol,
        sessionData: SessionData
    ) {
        self.apiClient = apiClient
        self.cacheManager = cacheManager
        self.sessionData = sessionData
    }

    public func iinDetails(
        forBin bin: String,
        forContext context: PaymentContext?,
        success: @escaping (_ iinDetailsResponse: IINDetailsResponse) -> Void,
        failure: @escaping (_ error: SdkError) -> Void,
    ) {
        if bin.count < 6 {
            let response = IINDetailsResponse(status: .notEnoughDigits)
            success(response)
            return
        }

        let cacheKey = "getIinDetails-\(bin)"

        if let cached: IINDetailsResponse = cacheManager.get(key: cacheKey) {
            success(cached)
            return
        }

        var parameters: [String: Any] = [
            "bin": iinDigitsFrom(bin: bin)
        ]

        if let context = context {
            parameters["paymentContext"] = [
                "isRecurring": context.isRecurring ? "true" : "false",
                "countryCode": context.countryCode,
                "amountOfMoney": [
                    "amount": String(context.amountOfMoney.amount),
                    "currencyCode": context.amountOfMoney.currencyCode,
                ],
            ]
        }

        let additionalAcceptableStatusCodes = IndexSet(integer: 404)
        let strongSelf = self

        iinLookupPending = true

        apiClient.post(
            path: "/services/getIINdetails",
            parameters: parameters,
            version: .v1,
            additionalAcceptableStatusCodes: additionalAcceptableStatusCodes,
            success: { (responseObject: IINDetailsResponse?, statusCode) in
                strongSelf.iinLookupPending = false

                validateResponse(
                    responseObject,
                    statusCode: statusCode,
                    message: "Could not fetch IinDetails.",
                    success: { validatedIinDetails in
                        strongSelf.cacheManager.set(key: cacheKey, value: validatedIinDetails)

                        success(validatedIinDetails)
                    },
                    failure: failure
                )
            },
            failure: { error in
                strongSelf.iinLookupPending = false
                failure(error)
            },
        )
    }

    public func currencyConversionQuote(
        withAmountOfMoney amountOfMoney: AmountOfMoney,
        forCardSource cardSource: CardSource,
        success: @escaping (_ currencyConversionResponse: CurrencyConversionResponse) -> Void,
        failure: @escaping (_ error: SdkError) -> Void,
    ) {
        let cacheKey = [
            "getCurrencyConversionQuote",
            "\(amountOfMoney.amount)",
            amountOfMoney.currencyCode,
            getCardNumberOrTokenSuffix(cardSource: cardSource),
        ].compactMap { $0 }.joined(separator: "-")

        if let cached: CurrencyConversionResponse = cacheManager.get(key: cacheKey) {
            success(cached)
            return
        }

        let parameters: [String: Any] = [
            "cardSource": getCardSourceParameter(cardSource: cardSource),
            "transaction": [
                "amount": getAmountOfMoneyParameter(amountOfMoney: amountOfMoney)
            ],
        ]

        let strongSelf = self

        apiClient.post(
            path: "/services/dccrate",
            parameters: parameters,
            version: .v1,
            additionalAcceptableStatusCodes: nil,
            success: { (responseObject: CurrencyConversionResponse?, statusCode) in
                validateResponse(
                    responseObject,
                    statusCode: statusCode,
                    message: "Could not fetch CurrencyConversionQuote.",
                    success: { validatedCurrencyConversionQuote in
                        strongSelf.cacheManager.set(key: cacheKey, value: validatedCurrencyConversionQuote)

                        success(validatedCurrencyConversionQuote)
                    },
                    failure: failure
                )
            },
            failure: { error in
                failure(error)
            },
        )
    }

    public func surchargeCalculation(
        withAmountOfMoney amountOfMoney: AmountOfMoney,
        forCardSource cardSource: CardSource,
        success: @escaping (_ surchargeCalculationResponse: SurchargeCalculationResponse) -> Void,
        failure: @escaping (_ error: SdkError) -> Void,
    ) {
        let cacheKey = [
            "getSurchargeCalculation",
            "\(amountOfMoney.amount)",
            amountOfMoney.currencyCode,
            getCardNumberOrTokenSuffix(cardSource: cardSource),
        ].compactMap { $0 }.joined(separator: "-")

        if let cached: SurchargeCalculationResponse = cacheManager.get(key: cacheKey) {
            success(cached)
            return
        }

        let parameters: [String: Any] = [
            "amountOfMoney": getAmountOfMoneyParameter(amountOfMoney: amountOfMoney),
            "cardSource": getCardSourceParameter(cardSource: cardSource),
        ]

        let strongSelf = self

        apiClient.post(
            path: "/services/surchargecalculation",
            parameters: parameters,
            version: .v1,
            additionalAcceptableStatusCodes: nil,
            success: { (responseObject: SurchargeCalculationResponse?, statusCode) in
                validateResponse(
                    responseObject,
                    statusCode: statusCode,
                    message: "Could not fetch SurchargeCalculation.",
                    success: { validatedCurrencyConversionQuote in
                        strongSelf.cacheManager.set(key: cacheKey, value: validatedCurrencyConversionQuote)

                        success(validatedCurrencyConversionQuote)
                    },
                    failure: failure
                )
            },
            failure: { error in
                failure(error)
            },
        )
    }

    private func iinDigitsFrom(bin: String) -> String {
        let max: Int
        if bin.count >= 8 {
            max = 8
        } else {
            max = min(bin.count, 6)
        }

        return String(
            bin[
                ..<bin.index(bin.startIndex, offsetBy: max)
            ]
        )
    }

    private func getCardNumberOrTokenSuffix(cardSource: CardSource) -> String? {
        if let card = cardSource.card {
            let cardNumber = card.cardNumber
            let suffix = String(cardNumber.suffix(4))
            return suffix
        } else if let token = cardSource.token {
            return token
        }

        return nil
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
            "token": cardSource.token,
        ].compactMapValues { $0 }
    }

    private func getAmountOfMoneyParameter(amountOfMoney: AmountOfMoney) -> [String: Any] {
        return [
            "amount": amountOfMoney.amount,
            "currencyCode": amountOfMoney.currencyCode,
        ]
    }
}
