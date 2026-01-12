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

@testable import OnlinePaymentsKit

class MockEncryptionService: EncryptionServiceProtocol {
    func getPublicKey(
        success: @escaping (OnlinePaymentsKit.PublicKeyResponse) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
    }

    func encryptPaymentRequest(
        _ paymentRequest: OnlinePaymentsKit.PaymentRequest,
        success: @escaping (OnlinePaymentsKit.EncryptedRequest) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
    }

    func encryptTokenRequest(
        _ tokenRequest: OnlinePaymentsKit.CreditCardTokenRequest,
        success: @escaping (OnlinePaymentsKit.EncryptedRequest) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
    }

}

class MockPaymentProductService: PaymentProductServiceProtocol {
    func paymentProducts(
        forContext context: OnlinePaymentsKit.PaymentContext,
        success: @escaping (OnlinePaymentsKit.BasicPaymentProducts) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
    }

    func paymentProduct(
        withId productId: Int,
        forContext context: OnlinePaymentsKit.PaymentContext,
        success: @escaping (OnlinePaymentsKit.PaymentProduct) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
    }

    func paymentProductNetworks(
        forProductId productId: Int,
        forContext context: OnlinePaymentsKit.PaymentContext,
        success: @escaping (OnlinePaymentsKit.PaymentProductNetworks) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
    }

    func checkAvailability(
        forProduct paymentProductId: Int,
        context: OnlinePaymentsKit.PaymentContext,
        success: @escaping () -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
    }
}

class MockClientService: ClientServiceProtocol {
    var iinLookupPending: Bool = false

    func iinDetails(
        forBin partialCardNumber: String,
        forContext context: OnlinePaymentsKit.PaymentContext?,
        success: @escaping (OnlinePaymentsKit.IINDetailsResponse) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
    }

    func currencyConversionQuote(
        withAmountOfMoney amountOfMoney: OnlinePaymentsKit.AmountOfMoney,
        forCardSource cardSource: OnlinePaymentsKit.CardSource,
        success: @escaping (OnlinePaymentsKit.CurrencyConversionResponse) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
    }

    func surchargeCalculation(
        withAmountOfMoney amountOfMoney: OnlinePaymentsKit.AmountOfMoney,
        forCardSource cardSource: OnlinePaymentsKit.CardSource,
        success: @escaping (OnlinePaymentsKit.SurchargeCalculationResponse) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
    }
}
