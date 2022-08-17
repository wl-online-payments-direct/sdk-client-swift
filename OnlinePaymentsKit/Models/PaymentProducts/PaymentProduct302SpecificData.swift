//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentProduct302SpecificData)
public class PaymentProduct302SpecificData: NSObject {
    @objc public var networks: [String] = []

    @objc public required init?(json: [String: Any]) {
        if let networks = json["networks"] as? [String] {
            self.networks = networks
        }
    }
}
