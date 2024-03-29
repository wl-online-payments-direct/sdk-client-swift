//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 11/03/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPCurrencyConversionResult)
public class CurrencyConversionResult: NSObject, Codable {
    @objc public var result: ConversionResultType = .notAvailable
    @objc public var resultReason: String?

    private enum CodingKeys: String, CodingKey {
        case result, resultReason
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.resultReason = try? container.decodeIfPresent(String.self, forKey: .resultReason)

        super.init()

        let resultString = try container.decode(String.self, forKey: .result)
        self.result = getConversionResultType(conversionResultType: resultString)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(getConversionResultTypeString(conversionResultType: result), forKey: .result)
        try? container.encodeIfPresent(resultReason, forKey: .resultReason)
    }

    private func getConversionResultType(conversionResultType: String) -> ConversionResultType {
        switch conversionResultType {
        case "Allowed":
            return .allowed
        case "InvalidCard":
            return .invalidCard
        case "InvalidMerchant":
            return .invalidMerchant
        case "NoRate":
            return .noRate
        case "NotAvailable":
            return .notAvailable
        default:
            return .notAvailable
        }
    }

    private func getConversionResultTypeString(conversionResultType: ConversionResultType) -> String {
        switch conversionResultType {
        case .allowed:
            return "Allowed"
        case .invalidCard:
            return "InvalidCard"
        case .invalidMerchant:
            return "InvalidMerchant"
        case .noRate:
            return "NoRate"
        case .notAvailable:
            return "NotAvailable"
        }
    }
}
