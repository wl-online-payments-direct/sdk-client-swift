/*
 * Do not remove or alter the notices in this preamble.
 *
 * This software is owned by Worldline and may not be be altered, copied, reproduced, republished, uploaded, posted, transmitted or distributed in any way, without the prior written consent of Worldline.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation

@testable import OnlinePaymentsKit

class EncryptionServiceMock: EncryptionServiceProtocol {
    func getPublicKey(
        success: @escaping (OnlinePaymentsKit.PublicKeyResponse) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
        fatalError("Not implemented: \(#function)")
    }

    func encryptPaymentRequest(
        _ paymentRequest: OnlinePaymentsKit.PaymentRequest,
        success: @escaping (OnlinePaymentsKit.EncryptedRequest) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
        fatalError("Not implemented: \(#function)")
    }

    func encryptTokenRequest(
        _ tokenRequest: OnlinePaymentsKit.CreditCardTokenRequest,
        success: @escaping (OnlinePaymentsKit.EncryptedRequest) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
        fatalError("Not implemented: \(#function)")
    }

}

class PaymentProductServiceMock: PaymentProductServiceProtocol {
    func paymentProducts(
        forContext context: OnlinePaymentsKit.PaymentContext,
        success: @escaping (OnlinePaymentsKit.BasicPaymentProducts) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
        fatalError("Not implemented: \(#function)")
    }

    func paymentProduct(
        withId productId: Int,
        forContext context: OnlinePaymentsKit.PaymentContext,
        success: @escaping (OnlinePaymentsKit.PaymentProduct) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
        fatalError("Not implemented: \(#function)")
    }

    func paymentProductNetworks(
        forProductId productId: Int,
        forContext context: OnlinePaymentsKit.PaymentContext,
        success: @escaping (OnlinePaymentsKit.PaymentProductNetworks) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
        fatalError("Not implemented: \(#function)")
    }

    func checkAvailability(
        forProduct paymentProductId: Int,
        context: OnlinePaymentsKit.PaymentContext,
        success: @escaping () -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
        fatalError("Not implemented: \(#function)")
    }
}

class ClientServiceMock: ClientServiceProtocol {
    var iinLookupPending: Bool = false

    func iinDetails(
        forBin partialCardNumber: String,
        forContext context: OnlinePaymentsKit.PaymentContext?,
        success: @escaping (OnlinePaymentsKit.IINDetailsResponse) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
        fatalError("Not implemented: \(#function)")
    }

    func currencyConversionQuote(
        withAmountOfMoney amountOfMoney: OnlinePaymentsKit.AmountOfMoney,
        forCardSource cardSource: OnlinePaymentsKit.CardSource,
        success: @escaping (OnlinePaymentsKit.CurrencyConversionResponse) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
        fatalError("Not implemented: \(#function)")
    }

    func surchargeCalculation(
        withAmountOfMoney amountOfMoney: OnlinePaymentsKit.AmountOfMoney,
        forCardSource cardSource: OnlinePaymentsKit.CardSource,
        success: @escaping (OnlinePaymentsKit.SurchargeCalculationResponse) -> Void,
        failure: @escaping (OnlinePaymentsKit.SdkError) -> Void
    ) {
        fatalError("Not implemented: \(#function)")
    }
}
