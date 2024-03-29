//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 31/07/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import Foundation

internal class CardSource: NSObject, Codable {
    var card: Card?
    var token: String?

    init(card: Card) {
        self.card = card
    }

    init(token: String) {
        self.token = token
    }
}
