//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 11/03/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPConversionResultType)
public enum ConversionResultType: Int, Codable {
    @objc(OPAllowed) case allowed
    @objc(OPInvalidCard) case invalidCard
    @objc(OPInvalidMerchant) case invalidMerchant
    @objc(OPNoRate) case noRate
    @objc(OPNotAvailable) case notAvailable
}
