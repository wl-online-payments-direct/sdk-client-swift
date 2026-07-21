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

internal protocol ClientServiceProtocol {

    var iinLookupPending: Bool { get }

    func iinDetails(
        forBin bin: String,
        forContext context: PaymentContext?,
        success: @escaping (_ iinDetailsResponse: IINDetailsResponse) -> Void,
        failure: @escaping (_ error: SdkError) -> Void,
    )

    func currencyConversionQuote(
        withAmountOfMoney amountOfMoney: AmountOfMoney,
        forCardSource cardSource: CardSource,
        success: @escaping (_ currencyConversionResponse: CurrencyConversionResponse) -> Void,
        failure: @escaping (_ error: SdkError) -> Void,
    )

    func surchargeCalculation(
        withAmountOfMoney amountOfMoney: AmountOfMoney,
        forCardSource cardSource: CardSource,
        success: @escaping (_ surchargeCalculationResponse: SurchargeCalculationResponse) -> Void,
        failure: @escaping (_ error: SdkError) -> Void,
    )
}
