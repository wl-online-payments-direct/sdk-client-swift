/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import PassKit

@objc(OPPaymentProductNetworks) public class PaymentProductNetworks: NSObject, Codable {

    @objc public var paymentProductNetworks = [PKPaymentNetwork]()

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
