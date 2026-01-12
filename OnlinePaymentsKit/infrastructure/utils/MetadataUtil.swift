/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import UIKit

internal class MetadataUtil {
    static let shared = MetadataUtil()
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
            "deviceType": deviceType,
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
            sdkIdentifier: SdkConstants.kSDKIdentifier
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
            Logger.log("Unable to serialize dictionary")
            return nil
        }

        return json.encode()
    }
}
