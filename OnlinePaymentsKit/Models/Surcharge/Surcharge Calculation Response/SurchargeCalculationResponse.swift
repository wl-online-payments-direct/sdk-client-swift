//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 31/07/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPSurchargeCalculationResponse)
public class SurchargeCalculationResponse: NSObject, Codable {
    @objc public var surcharges: [Surcharge] = []

    @available(
        *,
        deprecated,
        message: "Do not use this initializer, it is only for internal SDK use and will be removed in a future release."
    )
    @objc required public init(json: [String: Any]) {
        if let surcharges = json["surcharges"] as? [[String: Any]] {
            for surchargeInput in surcharges {
                if let surcharge = Surcharge(json: surchargeInput) {
                    self.surcharges.append(surcharge)
                }
            }
        }
    }
}
