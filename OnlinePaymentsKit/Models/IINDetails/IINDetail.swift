//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPIINDetail)
public class IINDetail: NSObject, Codable {
    @objc public var paymentProductId: String
    @objc(isAllowedInContext) public var allowedInContext: Bool = false
    @objc public var cardType: CardType = .credit

    enum CodingKeys: CodingKey {
        case paymentProductId, isAllowedInContext, cardType
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let paymentProductIdInt = try container.decode(Int.self, forKey: .paymentProductId)
        self.paymentProductId = "\(paymentProductIdInt)"

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

    internal init(paymentProductId: String, allowedInContext: Bool) {
        self.paymentProductId = paymentProductId
        self.allowedInContext = allowedInContext
    }
}
