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

@objc(OPRateDetails) public class RateDetails: NSObject, Codable {
    @objc public var exchangeRate: Double
    @objc public var invertedExchangeRate: Double
    @objc public var markUpRate: Double
    @objc public var quotationDateTime: String
    @objc public var source: String

    internal init(
        exchangeRate: Double,
        invertedExchangeRate: Double,
        markUpRate: Double,
        quotationDateTime: String,
        source: String
    ) {
        self.exchangeRate = exchangeRate
        self.invertedExchangeRate = invertedExchangeRate
        self.markUpRate = markUpRate
        self.quotationDateTime = quotationDateTime
        self.source = source
        super.init()
    }

    /// Placeholder used inside `DccProposal.absent()`.
    internal static func absent() -> RateDetails {
        return RateDetails(
            exchangeRate: 0,
            invertedExchangeRate: 0,
            markUpRate: 0,
            quotationDateTime: "",
            source: ""
        )
    }
}
