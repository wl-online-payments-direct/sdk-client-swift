//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import UIKit

public class Util {
    static let shared = Util()
    public var metaInfo: [String: String]?

    public var platformIdentifier: String {
        let OSName = UIDevice.current.systemName
        let OSVersion = UIDevice.current.systemVersion

        return "\(OSName)/\(OSVersion)"
    }

    public var screenSize: String {
        let screenBounds = UIScreen.main.bounds
        let screenScale = UIScreen.main.scale
        let screenSize = CGSize(width: CGFloat(screenBounds.size.width * screenScale), height: CGFloat(screenBounds.size.height * screenScale))

        return "\(Int(screenSize.width))\(Int(screenSize.height))"
    }

    public var deviceType: String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }

    public init() {
        metaInfo = [
            "platformIdentifier": platformIdentifier,
            "sdkIdentifier": "SwiftClientSDK/v2.0.0",
            "sdkCreator": "Online Payments",
            "screenSize": screenSize,
            "deviceBrand": "Apple",
            "deviceType": deviceType
        ]
    }

    public var base64EncodedClientMetaInfo: String? {
        return base64EncodedClientMetaInfo(withAppIdentifier: nil)
    }

    public func base64EncodedClientMetaInfo(withAddedData addedData: [String: String]) -> String? {
        return base64EncodedClientMetaInfo(withAppIdentifier: nil, ipAddress: nil, addedData: addedData)
    }

    public func base64EncodedClientMetaInfo(withAppIdentifier appIdentifier: String?) -> String? {
        return base64EncodedClientMetaInfo(withAppIdentifier: appIdentifier, ipAddress: nil, addedData: nil)
    }

    public func base64EncodedClientMetaInfo(withAppIdentifier appIdentifier: String?, ipAddress: String?) -> String? {
        return base64EncodedClientMetaInfo(withAppIdentifier: appIdentifier, ipAddress: ipAddress, addedData: nil)
    }

    public func base64EncodedClientMetaInfo(withAppIdentifier appIdentifier: String?, ipAddress: String?, addedData: [String: String]?) -> String? {
        if let addedData = addedData {
            for (k, v) in addedData {
                metaInfo!.updateValue(v, forKey: k)
            }
        }

        if let appIdentifier = appIdentifier, !appIdentifier.isEmpty {
            metaInfo!["appIdentifier"] = appIdentifier
        } else {
            metaInfo!["appIdentifier"] = "UNKNOWN"
        }

        if let ipAddress = ipAddress, !ipAddress.isEmpty {
            metaInfo!["ipAddress"] = ipAddress
        }

        return base64EncodedString(fromDictionary: metaInfo!)
    }

    //TODO: move to Base64 class
    public func base64EncodedString(fromDictionary dictionary: [AnyHashable: Any]) -> String? {
        guard let json = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
            Macros.DLog(message: "Unable to serialize dictionary")
            return nil
        }

        return json.encode()
    }
}
