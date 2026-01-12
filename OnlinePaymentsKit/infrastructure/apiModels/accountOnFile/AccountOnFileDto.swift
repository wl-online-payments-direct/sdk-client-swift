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

internal struct AccountOnFileDto: Codable {
    let id: String
    let paymentProductId: Int
    let attributes: [AccountOnFileAttributeDto]?
    let displayHints: AccountOnFileDisplayHintsDto?

    enum CodingKeys: String, CodingKey {
        case id
        case paymentProductId
        case attributes
        case displayHints
    }
}
