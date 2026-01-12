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

@objc(OPPaymentProduct320SpecificData) public class PaymentProduct320SpecificData: NSObject, Codable {
    @objc public var gateway: String = ""
    @objc public var networks: [String] = []

    private enum CodingKeys: String, CodingKey {
        case gateway, networks
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.gateway = (try? container.decode(String.self, forKey: .gateway)) ?? ""
        self.networks = (try? container.decode([String].self, forKey: .networks)) ?? []
    }
}
