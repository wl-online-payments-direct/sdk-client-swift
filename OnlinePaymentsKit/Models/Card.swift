//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 31/07/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import Foundation

internal class Card: NSObject, Codable {
    var cardNumber: String
    public var paymentProductId: Int?

    init(cardNumber: String, paymentProductId: Int?) {
        self.cardNumber = cardNumber
        self.paymentProductId = paymentProductId
    }
}
