//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPublicKeyResponse)
public class PublicKeyResponse: NSObject, Codable {
    @objc public var keyId: String
    @objc public var encodedPublicKey: String

    private enum CodingKeys: String, CodingKey {
        case keyId, publicKey
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.keyId = try container.decode(String.self, forKey: .keyId)
        self.encodedPublicKey = try container.decode(String.self, forKey: .publicKey)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(keyId, forKey: .keyId)
        try? container.encode(encodedPublicKey, forKey: .publicKey)
    }
}
