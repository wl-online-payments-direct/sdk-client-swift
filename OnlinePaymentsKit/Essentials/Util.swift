//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import UIKit

@objc(OPUtil)
public class Util: NSObject {
    @objc internal static let shared = Util()
    @objc public var metaInfo: [String: String]?

    @objc public var platformIdentifier: String {
        let OSName = UIDevice.current.systemName
        let OSVersion = UIDevice.current.systemVersion

        return "\(OSName)/\(OSVersion)"
    }

    @objc public var screenSize: String {
        let screenBounds = UIScreen.main.bounds
        let screenScale = UIScreen.main.scale
        let screenSize = CGSize(width: CGFloat(screenBounds.size.width * screenScale), height: CGFloat(screenBounds.size.height * screenScale))

        return "\(Int(screenSize.width))\(Int(screenSize.height))"
    }

    @objc public var deviceType: String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }

    @objc public override init() {
        super.init()
        metaInfo = [
            "platformIdentifier": platformIdentifier,
            "sdkIdentifier": "SwiftClientSDK/v2.0.2",
            "sdkCreator": "Online Payments",
            "screenSize": screenSize,
            "deviceBrand": "Apple",
            "deviceType": deviceType
        ]
    }

    @objc public var base64EncodedClientMetaInfo: String? {
        return base64EncodedClientMetaInfo(withAppIdentifier: nil)
    }

    @objc public func base64EncodedClientMetaInfo(withAddedData addedData: [String: String]) -> String? {
        return base64EncodedClientMetaInfo(withAppIdentifier: nil, ipAddress: nil, addedData: addedData)
    }

    @objc public func base64EncodedClientMetaInfo(withAppIdentifier appIdentifier: String?) -> String? {
        return base64EncodedClientMetaInfo(withAppIdentifier: appIdentifier, ipAddress: nil, addedData: nil)
    }

    @objc public func base64EncodedClientMetaInfo(withAppIdentifier appIdentifier: String?, ipAddress: String?) -> String? {
        return base64EncodedClientMetaInfo(withAppIdentifier: appIdentifier, ipAddress: ipAddress, addedData: nil)
    }

    @objc public func base64EncodedClientMetaInfo(withAppIdentifier appIdentifier: String?, ipAddress: String?, addedData: [String: String]?) -> String? {
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
    @objc public func base64EncodedString(fromDictionary dictionary: [AnyHashable: Any]) -> String? {
        guard let json = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
            Macros.DLog(message: "Unable to serialize dictionary")
            return nil
        }

        return json.encode()
    }
}
