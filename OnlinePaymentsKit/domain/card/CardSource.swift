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

public class CardSource: NSObject, Codable {
    var card: Card?
    var token: String?

    init(card: Card) {
        self.card = card
    }

    init(token: String) {
        self.token = token
    }
}
