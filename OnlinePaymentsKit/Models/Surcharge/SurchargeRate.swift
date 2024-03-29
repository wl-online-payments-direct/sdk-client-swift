//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 31/07/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPSurchargeRate)
public class SurchargeRate: NSObject, Codable {
    @objc public var surchargeProductTypeId: String
    @objc public var surchargeProductTypeVersion: String
    @objc public var adValoremRate: Double
    @objc public var specificRate: Int

    @available(
        *,
        deprecated,
        message: "Do not use this initializer, it is only for internal SDK use and will be removed in a future release."
    )
    @objc required public init?(json: [String: Any]) {
        guard let productTypeId = json["surchargeProductTypeId"] as? String,
              let productTypeVersion = json["surchargeProductTypeVersion"] as? String,
              let adValoremRate = json["adValoremRate"] as? Double,
              let specificRate = json["specificRate"] as? Int else {
            return nil
        }

        self.surchargeProductTypeId = productTypeId
        self.surchargeProductTypeVersion = productTypeVersion
        self.adValoremRate = adValoremRate
        self.specificRate = specificRate
    }
}
