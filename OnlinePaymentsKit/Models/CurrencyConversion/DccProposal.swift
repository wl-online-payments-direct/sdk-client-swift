//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 11/03/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPDccProposal)
public class DccProposal: NSObject, Codable {
    @objc public var baseAmount: AmountOfMoney
    @objc public var targetAmount: AmountOfMoney
    @objc public var rate: RateDetails
    @objc public var disclaimerReceipt: String?
    @objc public var disclaimerDisplay: String?
}
