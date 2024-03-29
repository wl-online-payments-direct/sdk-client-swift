//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 11/03/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPCurrencyConversionResponse)
public class CurrencyConversionResponse: NSObject, Codable {
    @objc public var dccSessionId: String
    @objc public var result: CurrencyConversionResult
    @objc public var proposal: DccProposal
}
