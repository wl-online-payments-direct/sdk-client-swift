/*
 * Do not remove or alter the notices in this preamble.
 *
 * This software is owned by Worldline and may not be be altered, copied, reproduced, republished, uploaded, posted, transmitted or distributed in any way, without the prior written consent of Worldline.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation

/// The surcharge calculated for one payment product.
///
/// The API does not always send the amounts (for example for `.noSurcharge`). The response still decodes,
/// and `netAmount`, `surchargeAmount` and `totalAmount` then hold a placeholder (amount 0, currency code
/// `UNKNOWN`). Read the amounts through `netAmountOrNil`, `surchargeAmountOrNil` and `totalAmountOrNil`,
/// which are `nil` when the API sent none.
@objc(OPSurcharge) public class Surcharge: NSObject, Codable {
    @objc public var paymentProductId: Int
    @objc public var result: SurchargeResult = .noSurcharge
    @objc public var surchargeRate: SurchargeRate?

    private var netAmountStorage: AmountOfMoney?
    private var surchargeAmountStorage: AmountOfMoney?
    private var totalAmountStorage: AmountOfMoney?

    /// The net amount, or a placeholder (amount 0, currency code `UNKNOWN`) when the API sent none.
    @objc public var netAmount: AmountOfMoney {
        get { netAmountStorage ?? AmountOfMoney.unknown() }
        set { netAmountStorage = newValue }
    }

    /// The surcharge amount, or a placeholder (amount 0, currency code `UNKNOWN`) when the API sent none.
    @objc public var surchargeAmount: AmountOfMoney {
        get { surchargeAmountStorage ?? AmountOfMoney.unknown() }
        set { surchargeAmountStorage = newValue }
    }

    /// The total amount, or a placeholder (amount 0, currency code `UNKNOWN`) when the API sent none.
    @objc public var totalAmount: AmountOfMoney {
        get { totalAmountStorage ?? AmountOfMoney.unknown() }
        set { totalAmountStorage = newValue }
    }

    /// The `netAmount`, or `nil` when the API sent none.
    @objc public var netAmountOrNil: AmountOfMoney? {
        return netAmountStorage
    }

    /// The `surchargeAmount`, or `nil` when the API sent none.
    @objc public var surchargeAmountOrNil: AmountOfMoney? {
        return surchargeAmountStorage
    }

    /// The `totalAmount`, or `nil` when the API sent none.
    @objc public var totalAmountOrNil: AmountOfMoney? {
        return totalAmountStorage
    }

    private enum CodingKeys: String, CodingKey {
        case paymentProductId, result, netAmount, surchargeAmount, totalAmount, surchargeRate
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.paymentProductId = try container.decode(Int.self, forKey: .paymentProductId)
        self.netAmountStorage = try? container.decodeIfPresent(AmountOfMoney.self, forKey: .netAmount)
        self.surchargeAmountStorage = try? container.decodeIfPresent(AmountOfMoney.self, forKey: .surchargeAmount)
        self.totalAmountStorage = try? container.decodeIfPresent(AmountOfMoney.self, forKey: .totalAmount)
        self.surchargeRate = try? container.decodeIfPresent(SurchargeRate.self, forKey: .surchargeRate)

        super.init()

        let resultString = try container.decode(String.self, forKey: .result)
        self.result = getSurchargeResult(surchargeResult: resultString)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(paymentProductId, forKey: .paymentProductId)
        try? container.encodeIfPresent(netAmountStorage, forKey: .netAmount)
        try? container.encodeIfPresent(surchargeAmountStorage, forKey: .surchargeAmount)
        try? container.encodeIfPresent(totalAmountStorage, forKey: .totalAmount)
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
