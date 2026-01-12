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

@objc(OPDccProposal) public class DccProposal: NSObject, Codable {
    @objc public var baseAmount: AmountOfMoney
    @objc public var targetAmount: AmountOfMoney
    @objc public var rate: RateDetails
    @objc public var disclaimerReceipt: String?
    @objc public var disclaimerDisplay: String?
}
