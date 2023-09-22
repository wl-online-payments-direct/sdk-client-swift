//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 31/07/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPSurcharge)
public class Surcharge: NSObject, ResponseObjectSerializable {
    @objc public var paymentProductId: Int
    @objc public var result: SurchargeResult = .noSurcharge
    @objc public var netAmount: AmountOfMoney
    @objc public var surchargeAmount: AmountOfMoney
    @objc public var totalAmount: AmountOfMoney
    @objc public var surchargeRate: SurchargeRate?

    @available(*, deprecated, message: "Do not use this initializer, it is only for internal SDK use and will be removed in a future release.")
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
}
