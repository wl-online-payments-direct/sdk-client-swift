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

@objc(OPEncryptedRequest) public class EncryptedRequest: NSObject, Codable {

    @objc public var encryptedCustomerInput: String
    @objc public var encodedClientMetaInfo: String

    internal init(encryptedCustomerInput: String, encodedClientMetaInfo mediaInfo: String) {
        self.encryptedCustomerInput = encryptedCustomerInput
        self.encodedClientMetaInfo = mediaInfo
    }
}
