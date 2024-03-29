//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 28/09/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPPaymentProduct320SpecificData)
public class PaymentProduct320SpecificData: NSObject, Codable {
    @objc public var gateway: String = ""
    @objc public var networks: [String] = []

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    internal init?(json: [String: Any]) {
        if let gateway = json["gateway"] as? String {
            self.gateway = gateway
        }
        if let networks = json["networks"] as? [String] {
            self.networks = networks
        }
    }

    private enum CodingKeys: String, CodingKey {
        case gateway, networks
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.gateway = (try? container.decode(String.self, forKey: .gateway)) ?? ""
        self.networks = (try? container.decode([String].self, forKey: .networks)) ?? []
    }
}
