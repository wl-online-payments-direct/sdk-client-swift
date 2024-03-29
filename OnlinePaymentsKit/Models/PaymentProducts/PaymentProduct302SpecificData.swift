//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPaymentProduct302SpecificData)
public class PaymentProduct302SpecificData: NSObject, Codable {
    @objc public var networks: [String] = []

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    @objc public required init?(json: [String: Any]) {
        if let networks = json["networks"] as? [String] {
            self.networks = networks
        }
    }

    private enum CodingKeys: String, CodingKey {
        case networks
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.networks = (try? container.decode([String].self, forKey: .networks)) ?? []
    }
}
