//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPC2SCommunicatorConfiguration)
public class C2SCommunicatorConfiguration: NSObject {
    internal let clientSessionId: String
    internal let customerId: String
    internal let util: Util
    internal let appIdentifier: String
    internal let ipAddress: String?
    internal let assetsBaseURL: String
    
    private var _baseURL: String
        var baseURL: String {
            return fixURL(url: _baseURL) ?? _baseURL
        }

    @objc public init(clientSessionId: String, customerId: String, baseURL: String, assetBaseURL: String, appIdentifier: String, util: Util? = nil) {
        self.clientSessionId = clientSessionId
        self.customerId = customerId
        self.util = util ?? Util.shared
        self.appIdentifier = appIdentifier
        self.ipAddress = nil
        self._baseURL = baseURL
        self.assetsBaseURL = assetBaseURL
    }
    @objc public init(clientSessionId: String, customerId: String, baseURL: String, assetBaseURL: String, appIdentifier: String, ipAddress: String?, util: Util? = nil) {
        self.clientSessionId = clientSessionId
        self.customerId = customerId
        self.util = util ?? Util.shared
        self.appIdentifier = appIdentifier
        self.ipAddress = ipAddress
        self._baseURL = baseURL
        self.assetsBaseURL = assetBaseURL
    }

    private func fixURL(url: String) -> String? {
        // Assume valid URL
        if var finalComponents = URLComponents(string: url) {
            var components = finalComponents.path.split(separator: "/").map { String($0)}
            let versionComponents = (SDKConstants.kApiVersion as NSString).pathComponents
            let error = {
                fatalError("This version of the OnlinePayments SDK is only compatible with \(versionComponents.joined(separator: "/")) , you supplied: '\(components.joined(separator: "/"))'")
            }

            switch components.count {
            case 0:
                components = versionComponents
            case 1:
                if components[0] != versionComponents[0] {
                    error()
                }
                components[0] = components[0]
                components.append(versionComponents[1])
            case 2:
                if components[0] != versionComponents[0] {
                    error()
                }
                if components[1] != versionComponents[1] {
                    error()
                }
            default:
                error()

            }
            finalComponents.path = "/" + components.joined(separator: "/")
            return finalComponents.url?.absoluteString
        }
        return nil
    }

    @objc public var base64EncodedClientMetaInfo: String? {
        return util.base64EncodedClientMetaInfo(withAppIdentifier: appIdentifier, ipAddress: ipAddress)
    }
}
