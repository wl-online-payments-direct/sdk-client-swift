//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentProduct302SpecificData {
    public var networks: [String] = []

    public required init?(json: [String: Any]) {
        if let networks = json["networks"] as? [String] {
            self.networks = networks
        }
    }
}
