//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

@testable import IngenicoDirectKit

class StubUtil: Util {

    override func C2SBaseURL(by region: Region, environment: Environment) -> String {
        return "c2sbaseurlbyregion"
    }

    override func assetsBaseURL(by region: Region, environment: Environment) -> String {
        return "assetsbaseurlbyregion"
    }

    override func base64EncodedClientMetaInfo(withAppIdentifier appIdentifier: String?, ipAddress: String?) -> String? {
        return "base64encodedclientmetainfo"
    }
}
