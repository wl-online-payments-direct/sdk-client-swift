//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 11/03/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPRateDetails)
public class RateDetails: NSObject, Codable {
    @objc public var exchangeRate: Double
    @objc public var invertedExchangeRate: Double
    @objc public var markUpRate: Double
    @objc public var quotationDateTime: String
    @objc public var source: String
}
