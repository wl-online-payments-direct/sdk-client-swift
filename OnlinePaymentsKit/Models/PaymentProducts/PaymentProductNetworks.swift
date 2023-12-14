//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import PassKit

@objc(OPPaymentProductNetworks)
public class PaymentProductNetworks: NSObject, Codable {

    @objc public var paymentProductNetworks = [PKPaymentNetwork]()

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    @objc public override init() {
        super.init()
    }

    private enum CodingKeys: String, CodingKey {
        case networks
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let networks = try? container.decode([String].self, forKey: .networks) {
            for network in networks {
                let paymentNetwork = PKPaymentNetwork(rawValue: network)
                self.paymentProductNetworks.append(paymentNetwork)
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        var networks = [String]()

        for network in paymentProductNetworks {
            networks.append(network.rawValue)
        }

        try? container.encode(networks, forKey: .networks)
    }
}
