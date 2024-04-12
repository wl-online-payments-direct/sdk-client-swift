//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import UIKit

internal class Util {
    static let shared = Util()
    var metaInfo: [String: String]?

    var platformIdentifier: String {
        let OSName = UIDevice.current.systemName
        let OSVersion = UIDevice.current.systemVersion

        return "\(OSName)/\(OSVersion)"
    }

    var screenSize: String {
        let screenBounds = UIScreen.main.bounds
        let screenScale = UIScreen.main.scale
        let screenSize =
            CGSize(
                width: CGFloat(screenBounds.size.width * screenScale),
                height: CGFloat(screenBounds.size.height * screenScale)
            )

        return "\(Int(screenSize.width))\(Int(screenSize.height))"
    }

    var deviceType: String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }

    init() {
        metaInfo = [
            "platformIdentifier": platformIdentifier,
            "sdkCreator": "Online Payments",
            "screenSize": screenSize,
            "deviceBrand": "Apple",
            "deviceType": deviceType
        ]
    }

    var base64EncodedClientMetaInfo: String? {
        return base64EncodedClientMetaInfo(withAppIdentifier: nil)
    }

    func base64EncodedClientMetaInfo(withAddedData addedData: [String: String]) -> String? {
        return base64EncodedClientMetaInfo(withAppIdentifier: nil, addedData: addedData)
    }

    func base64EncodedClientMetaInfo(withAppIdentifier appIdentifier: String?) -> String? {
        return base64EncodedClientMetaInfo(withAppIdentifier: appIdentifier, addedData: nil)
    }

    func base64EncodedClientMetaInfo(
        withAppIdentifier appIdentifier: String?,
        addedData: [String: String]?
    ) -> String? {
        return base64EncodedClientMetaInfo(
            withAppIdentifier: appIdentifier,
            addedData: addedData,
            sdkIdentifier: SDKConstants.kSDKIdentifier
        )
    }

    internal func base64EncodedClientMetaInfo(
        withAppIdentifier appIdentifier: String?,
        addedData: [String: String]?,
        sdkIdentifier: String
    ) -> String? {
        if let addedData = addedData {
            for (key, value) in addedData {
                metaInfo!.updateValue(value, forKey: key)
            }
        }

        if let appIdentifier = appIdentifier, !appIdentifier.isEmpty {
            metaInfo!["appIdentifier"] = appIdentifier
        } else {
            metaInfo!["appIdentifier"] = "UNKNOWN"
        }

        metaInfo!["sdkIdentifier"] = sdkIdentifier

        return base64EncodedString(fromDictionary: metaInfo!)
    }

    func base64EncodedString(fromDictionary dictionary: [AnyHashable: Any]) -> String? {
        guard let json = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
            Macros.DLog(message: "Unable to serialize dictionary")
            return nil
        }

        return json.encode()
    }
}
