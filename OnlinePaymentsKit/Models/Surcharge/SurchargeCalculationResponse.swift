//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 31/07/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPSurchargeCalculationResponse)
public class SurchargeCalculationResponse: NSObject, Codable {
    @objc public var surcharges: [Surcharge] = []
}
