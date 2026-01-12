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

@objc(OPIINDetailsResponse) public class IINDetailsResponse: NSObject, Codable {

    public var paymentProductId: Int?
    @objc public var paymentProductIdValue: NSNumber? {
        guard let paymentProductId = paymentProductId else { return nil }
        return NSNumber(value: paymentProductId)
    }
    @objc public var status: IINStatus = .supported
    @objc public var coBrands = [IINDetail]()
    @objc public var countryCode: String?
    @objc public var allowedInContext = false
    @objc public var cardType: CardType = .credit

    private override init() {
        self.paymentProductId = nil
    }

    private enum CodingKeys: String, CodingKey {
        case paymentProductId, coBrands, countryCode, isAllowedInContext, status, cardType
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let allowedInContext = try? container.decodeIfPresent(Bool.self, forKey: .isAllowedInContext) {
            self.allowedInContext = allowedInContext
        }

        if let paymentProductId = try? container.decodeIfPresent(Int.self, forKey: .paymentProductId) {
            self.paymentProductId = paymentProductId
            if !allowedInContext {
                status = .existingButNotAllowed
            }
        } else {
            paymentProductId = nil
            status = .unknown
        }

        if let countryCodeString = try? container.decodeIfPresent(String.self, forKey: .countryCode) {
            self.countryCode = countryCodeString
        }

        if let coBrands = try? container.decodeIfPresent([IINDetail].self, forKey: .coBrands) {
            self.coBrands = coBrands
        }

        if let cardTypeString = try? container.decodeIfPresent(String.self, forKey: .cardType) {
            self.cardType = CardTypeEnumHandler.getCardType(type: cardTypeString)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(paymentProductId, forKey: .paymentProductId)
        try? container.encode(coBrands, forKey: .coBrands)
        try? container.encodeIfPresent(countryCode, forKey: .countryCode)
        try? container.encode(allowedInContext, forKey: .isAllowedInContext)
        try? container.encode(getIINStatusString(status: status), forKey: .status)
        try? container.encode(CardTypeEnumHandler.getCardTypeString(type: cardType), forKey: .cardType)
    }

    internal convenience init(status: IINStatus) {
        self.init()
        self.status = status
    }

    private func getIINStatusString(status: IINStatus) -> String {
        switch status {
        case .supported:
            return "SUPPORTED"
        case .unknown:
            return "UNKNOWN"
        case .notEnoughDigits:
            return "NOT_ENOUGH_DIGITS"
        case .existingButNotAllowed:
            return "EXISTING_BUT_NOT_ALLOWED"
        }
    }
}
