//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

internal class C2SCommunicatorConfiguration {
    let clientSessionId: String
    let customerId: String
    let util: Util
    let appIdentifier: String
    let assetsBaseURL: String
    var loggingEnabled: Bool = false

    private let _baseURL: String
    var baseURL: String {
        return fixURL(url: _baseURL) ?? _baseURL
    }

    init(
        clientSessionId: String,
        customerId: String,
        baseURL: String,
        assetBaseURL: String,
        appIdentifier: String,
        util: Util? = nil,
        loggingEnabled: Bool = false
    ) {
        self.clientSessionId = clientSessionId
        self.customerId = customerId
        self.util = util ?? Util.shared
        self.appIdentifier = appIdentifier
        self._baseURL = baseURL
        self.assetsBaseURL = assetBaseURL
        self.loggingEnabled = loggingEnabled
    }

    internal func getUrl(version: ApiVersion, apiUrl: String) -> String {
        return baseURL + version.rawValue + apiUrl
    }

    private func fixURL(url: String) -> String? {
        if var finalComponents = URLComponents(string: url) {
            finalComponents.path.appendIf(where: { path in !path.hasSuffix("/") }, text: "/")
            finalComponents.path.appendIf(
                where: { path in !path.lowercased().hasSuffix(SDKConstants.kApiBase) },
                text: SDKConstants.kApiBase
            )

            return finalComponents.url?.absoluteString
        }

        return nil
    }

    var base64EncodedClientMetaInfo: String? {
        return util.base64EncodedClientMetaInfo(withAppIdentifier: appIdentifier)
    }
}
