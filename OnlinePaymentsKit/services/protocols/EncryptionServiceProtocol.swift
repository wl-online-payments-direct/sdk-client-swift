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

public protocol EncryptionServiceProtocol {
    func getPublicKey(
        success: @escaping (_ publicKeyResponse: PublicKeyResponse) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    )

    func encryptPaymentRequest(
        _ paymentRequest: PaymentRequest,
        success: @escaping (_ encryptedRequest: EncryptedRequest) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    )

    func encryptTokenRequest(
        _ tokenRequest: CreditCardTokenRequest,
        success: @escaping (_ encryptedRequest: EncryptedRequest) -> Void,
        failure: @escaping (_ error: SdkError) -> Void
    )
}
