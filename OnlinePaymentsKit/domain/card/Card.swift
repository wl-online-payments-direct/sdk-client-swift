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

internal class Card: NSObject, Codable {
    var cardNumber: String
    public var paymentProductId: Int?

    init(cardNumber: String, paymentProductId: Int?) {
        self.cardNumber = cardNumber
        self.paymentProductId = paymentProductId
    }
}
