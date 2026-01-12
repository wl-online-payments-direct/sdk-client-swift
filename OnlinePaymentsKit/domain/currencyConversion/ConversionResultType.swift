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

@objc(OPConversionResultType) public enum ConversionResultType: Int, Codable {
    @objc(OPAllowed) case allowed
    @objc(OPInvalidCard) case invalidCard
    @objc(OPInvalidMerchant) case invalidMerchant
    @objc(OPNoRate) case noRate
    @objc(OPNotAvailable) case notAvailable
}
