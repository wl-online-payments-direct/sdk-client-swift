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

public protocol PaymentProductServiceProtocol {

    func paymentProducts(
        forContext context: PaymentContext,
        success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void,
        failure: @escaping (_ error: SdkError) -> Void,
    )

    func paymentProduct(
        withId productId: Int,
        forContext context: PaymentContext,
        success: @escaping (_ paymentProduct: PaymentProduct) -> Void,
        failure: @escaping (_ error: SdkError) -> Void,
    )

    func paymentProductNetworks(
        forProductId productId: Int,
        forContext context: PaymentContext,
        success: @escaping (_ networks: PaymentProductNetworks) -> Void,
        failure: @escaping (_ error: SdkError) -> Void,
    )

    func checkAvailability(
        forProduct paymentProductId: Int,
        context: PaymentContext,
        success: @escaping () -> Void,
        failure: @escaping (_ error: SdkError) -> Void,
    )
}
