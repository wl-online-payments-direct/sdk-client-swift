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

@objc(OPPublicKeyResponse) public class PublicKeyResponse: NSObject, Codable {
    @objc public var keyId: String
    @objc public var publicKey: String

    private enum CodingKeys: String, CodingKey {
        case keyId, publicKey
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.keyId = try container.decode(String.self, forKey: .keyId)
        self.publicKey = try container.decode(String.self, forKey: .publicKey)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(keyId, forKey: .keyId)
        try? container.encode(publicKey, forKey: .publicKey)
    }
}
