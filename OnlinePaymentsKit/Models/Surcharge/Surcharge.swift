//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 31/07/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPSurcharge)
public class Surcharge: NSObject, Codable {
    @objc public var paymentProductId: Int
    @objc public var result: SurchargeResult = .noSurcharge
    @objc public var netAmount: AmountOfMoney
    @objc public var surchargeAmount: AmountOfMoney
    @objc public var totalAmount: AmountOfMoney
    @objc public var surchargeRate: SurchargeRate?

    @available(
        *,
        deprecated,
        message: "Do not use this initializer, it is only for internal SDK use and will be removed in a future release."
    )
    @objc required public init?(json: [String: Any]) {
        guard let paymentProductId = json["paymentProductId"] as? Int,
              let netAmountDictionary = json["netAmount"] as? [String: Any],
              let netAmount = AmountOfMoney(json: netAmountDictionary),
              let surchargeAmountDictionary = json["surchargeAmount"] as? [String: Any],
              let surchargeAmount = AmountOfMoney(json: surchargeAmountDictionary),
              let totalAmountDictionary = json["totalAmount"] as? [String: Any],
              let totalAmount = AmountOfMoney(json: totalAmountDictionary) else {
            return nil
        }

        self.paymentProductId = paymentProductId
        self.netAmount = netAmount
        self.surchargeAmount = surchargeAmount
        self.totalAmount = totalAmount

        if let input = json["surchargeRate"] as? [String: Any] {
            surchargeRate = SurchargeRate(json: input)
        }

        super.init()

        if let input = json["result"] as? String {
            result = getSurchargeResult(surchargeResult: input)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case paymentProductId, result, netAmount, surchargeAmount, totalAmount, surchargeRate
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.paymentProductId = try container.decode(Int.self, forKey: .paymentProductId)
        self.netAmount = try container.decode(AmountOfMoney.self, forKey: .netAmount)
        self.surchargeAmount = try container.decode(AmountOfMoney.self, forKey: .surchargeAmount)
        self.totalAmount = try container.decode(AmountOfMoney.self, forKey: .totalAmount)
        self.surchargeRate = try? container.decodeIfPresent(SurchargeRate.self, forKey: .surchargeRate)

        super.init()

        let resultString = try container.decode(String.self, forKey: .result)
        self.result = getSurchargeResult(surchargeResult: resultString)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(paymentProductId, forKey: .paymentProductId)
        try? container.encode(netAmount, forKey: .netAmount)
        try? container.encode(surchargeAmount, forKey: .surchargeAmount)
        try? container.encode(totalAmount, forKey: .totalAmount)
        try? container.encodeIfPresent(surchargeRate, forKey: .surchargeRate)
        try? container.encode(getSurchargeResultString(surchargeResult: result), forKey: .result)
    }

    private func getSurchargeResult(surchargeResult: String) -> SurchargeResult {
        switch surchargeResult {
        case "OK":
            return .ok
        case "NO_SURCHARGE":
            return .noSurcharge
        default:
            return .noSurcharge
        }
    }

    private func getSurchargeResultString(surchargeResult: SurchargeResult) -> String {
        switch surchargeResult {
        case .ok:
            return "OK"
        case .noSurcharge:
            return "NO_SURCHARGE"
        }
    }
}
