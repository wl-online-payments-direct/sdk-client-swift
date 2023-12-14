//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPIINDetailsResponse)
public class IINDetailsResponse: NSObject, Codable, ResponseObjectSerializable {

    @objc public var paymentProductId: String?
    @objc public var status: IINStatus = .supported
    @objc public var coBrands = [IINDetail]()
    @available(
        *,
        deprecated,
        message: "Use countryCodeString instead. In a future release, this field will become 'String' type."
    )
    public var countryCode: CountryCode?
    @objc public var countryCodeString: String?
    @objc public var allowedInContext = false
    @objc public var cardType: CardType = .credit

    private override init() {}

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    @objc required public init(json: [String: Any]) {
        if let input = json["isAllowedInContext"] as? Bool {
            allowedInContext = input
        }

        if let input = json["paymentProductId"] as? Int {
            paymentProductId = "\(input)"
            if !allowedInContext {
                status = .existingButNotAllowed
            }
        } else {
            status = .unknown
        }

        if let input = json["countryCode"] as? String {
            countryCode = CountryCode.init(rawValue: input)
            countryCodeString = input
        }

        if let input = json["coBrands"] as? [[String: Any]] {
            coBrands = []
            for detailInput in input {
                if let detail = IINDetail(json: detailInput) {
                    coBrands.append(detail)
                }
            }
        }

        if let input = json["cardType"] as? String {
            cardType = CardTypeEnumHandler.getCardType(type: input)
        }
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
            self.paymentProductId = "\(paymentProductId)"
            if !allowedInContext {
                status = .existingButNotAllowed
            }
        } else {
            status = .unknown
        }

        if let countryCodeString = try? container.decodeIfPresent(String.self, forKey: .countryCode) {
            self.countryCodeString = countryCodeString
            self.countryCode = CountryCode.init(rawValue: countryCodeString)
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
        try? container.encodeIfPresent(countryCodeString, forKey: .countryCode)
        try? container.encode(allowedInContext, forKey: .isAllowedInContext)
        try? container.encode(getIINStatusString(status: status), forKey: .status)
        try? container.encode(CardTypeEnumHandler.getCardTypeString(type: cardType), forKey: .cardType)
    }

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    @objc convenience public init(status: IINStatus) {
        self.init()
        self.status = status
    }

    @available(*, deprecated, message: "Use init(String:IINStatus:[IINDetail]:String:Bool:) instead.")
    public convenience init(
        paymentProductId: String,
        status: IINStatus,
        coBrands: [IINDetail],
        countryCode: CountryCode,
        allowedInContext: Bool
    ) {
        self.init(
            paymentProductId: paymentProductId,
            status: status,
            coBrands: coBrands,
            countryCode: countryCode.rawValue,
            allowedInContext: allowedInContext
        )
    }

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    @objc public init(
        paymentProductId: String,
        status: IINStatus,
        coBrands: [IINDetail],
        countryCode: String,
        allowedInContext: Bool
    ) {
        self.paymentProductId = paymentProductId
        self.status = status
        self.coBrands = coBrands
        self.countryCode = CountryCode.init(rawValue: countryCode)
        self.countryCodeString = countryCode
        self.allowedInContext = allowedInContext
    }

    private func getIINStatusString(status: IINStatus) -> String {
        switch status {
        case .supported:
            return "SUPPORTED"
        case .unsupported:
            return "UNSUPPORTED"
        case .unknown:
            return "UNKNOWN"
        case .notEnoughDigits:
            return "NOT_ENOUGH_DIGITS"
        case .pending:
            return "PENDING"
        case .existingButNotAllowed:
            return "EXISTING_BUT_NOT_ALLOWED"
        }
    }
}
