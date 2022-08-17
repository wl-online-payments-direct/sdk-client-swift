//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPPublicKeyResponse)
public class PublicKeyResponse: NSObject {
    @objc public var keyId: String
    @objc public var encodedPublicKey: String

    @objc public init(keyId: String, encodedPublicKey: String) {
        self.keyId = keyId
        self.encodedPublicKey = encodedPublicKey
    }
}
