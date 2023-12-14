//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPIINDetail)
public class IINDetail: NSObject, Codable, ResponseObjectSerializable {
    @objc public var paymentProductId: String
    @objc(isAllowedInContext) public var allowedInContext: Bool = false
    @objc public var cardType: CardType = .credit

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    @objc required public init?(json: [String: Any]) {
        if let input = json["paymentProductId"] as? Int {
            paymentProductId = "\(input)"
        } else {
            return nil
        }
        if let input = json["isAllowedInContext"] as? Bool {
            allowedInContext = input
        }
        if let input = json["cardType"] as? String {
            cardType = CardTypeEnumHandler.getCardType(type: input)
        }
    }

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

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    @objc public init(paymentProductId: String, allowedInContext: Bool) {
        self.paymentProductId = paymentProductId
        self.allowedInContext = allowedInContext
    }
}
