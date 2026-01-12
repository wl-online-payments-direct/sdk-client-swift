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

@objc(OPIINDetail) public class IINDetail: NSObject, Codable {
    @objc public var paymentProductId: Int
    @objc(isAllowedInContext) public var allowedInContext: Bool = false
    @objc public var cardType: CardType = .credit

    enum CodingKeys: CodingKey {
        case paymentProductId, isAllowedInContext, cardType
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.paymentProductId = try container.decode(Int.self, forKey: .paymentProductId)

        if let allowedInContext = try? container.decodeIfPresent(Bool.self, forKey: .isAllowedInContext) {
            self.allowedInContext = allowedInContext
        }

        if let cardTypeString = try? container.decodeIfPresent(String.self, forKey: .cardType) {
            self.cardType = CardTypeEnumHandler.getCardType(type: cardTypeString)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(paymentProductId, forKey: .paymentProductId)
        try? container.encode(allowedInContext, forKey: .isAllowedInContext)
        try? container.encode(CardTypeEnumHandler.getCardTypeString(type: cardType), forKey: .cardType)
    }

    internal init(paymentProductId: Int, allowedInContext: Bool) {
        self.paymentProductId = paymentProductId
        self.allowedInContext = allowedInContext
    }
}
