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

@objc(OPDccProposal) public class DccProposal: NSObject, Codable {
    @objc public var baseAmount: AmountOfMoney
    @objc public var targetAmount: AmountOfMoney
    @objc public var rate: RateDetails
    @objc public var disclaimerReceipt: String?
    @objc public var disclaimerDisplay: String?

    internal init(
        baseAmount: AmountOfMoney,
        targetAmount: AmountOfMoney,
        rate: RateDetails,
        disclaimerReceipt: String? = nil,
        disclaimerDisplay: String? = nil
    ) {
        self.baseAmount = baseAmount
        self.targetAmount = targetAmount
        self.rate = rate
        self.disclaimerReceipt = disclaimerReceipt
        self.disclaimerDisplay = disclaimerDisplay
        super.init()
    }

    /// Placeholder returned by `CurrencyConversionResponse.proposal` when the API sent no proposal.
    internal static func absent() -> DccProposal {
        return DccProposal(
            baseAmount: AmountOfMoney.unknown(),
            targetAmount: AmountOfMoney.unknown(),
            rate: RateDetails.absent()
        )
    }
}
