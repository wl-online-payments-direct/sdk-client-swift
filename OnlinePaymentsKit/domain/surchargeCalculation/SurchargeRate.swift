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

@objc(OPSurchargeRate) public class SurchargeRate: NSObject, Codable {
    @objc public var surchargeProductTypeId: String
    @objc public var surchargeProductTypeVersion: String
    @objc public var adValoremRate: Double
    @objc public var specificRate: Int

    private enum CodingKeys: String, CodingKey {
        case surchargeProductTypeId
        case surchargeProductTypeVersion
        case adValoremRate
        case specificRate
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.surchargeProductTypeId = try container.decode(String.self, forKey: .surchargeProductTypeId)
        self.surchargeProductTypeVersion = try container.decode(String.self, forKey: .surchargeProductTypeVersion)
        self.adValoremRate = try container.decode(Double.self, forKey: .adValoremRate)
        self.specificRate = try container.decode(Int.self, forKey: .specificRate)
    }
}
