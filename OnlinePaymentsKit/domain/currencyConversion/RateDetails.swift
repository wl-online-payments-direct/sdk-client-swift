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

@objc(OPRateDetails) public class RateDetails: NSObject, Codable {
    @objc public var exchangeRate: Double
    @objc public var invertedExchangeRate: Double
    @objc public var markUpRate: Double
    @objc public var quotationDateTime: String
    @objc public var source: String
}
