//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

public class PreparedPaymentRequest {

    public var encryptedFields: String
    public var encodedClientMetaInfo: String

    init(encryptedFields: String, encodedClientMetaInfo mediaInfo: String) {
        self.encryptedFields = encryptedFields
        self.encodedClientMetaInfo = mediaInfo
    }
}
