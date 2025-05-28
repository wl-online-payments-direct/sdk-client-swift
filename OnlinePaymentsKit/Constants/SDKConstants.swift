//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

@objc(OPSDKConstants)

public class SDKConstants: NSObject {
    internal static let kApplePayIdentifier = "302"

    internal static let kApiBase = "client/"
    internal static let kSDKIdentifier = "SwiftClientSDK/v4.1.0"

#if SWIFT_PACKAGE
    @objc(kOPSDKBundlePath)
    public static var kSDKBundlePath = Bundle.module.path(forResource: "OnlinePaymentsKit", ofType: "bundle")
#elseif COCOAPODS
    private static let kSDKBundleIdentifier = "org.cocoapods.OnlinePaymentsKit"
    @objc(kOPSDKBundlePath)
    public static var kSDKBundlePath =
        Bundle(identifier: SDKConstants.kSDKBundleIdentifier)?.path(forResource: "OnlinePaymentsKit", ofType: "bundle")
#else
    private static let kSDKBundleIdentifier = "com.onlinepayments.OnlinePaymentsKit"
    @objc(kOPSDKBundlePath)
    public static var kSDKBundlePath =
        Bundle(identifier: SDKConstants.kSDKBundleIdentifier)?.path(forResource: "OnlinePaymentsKit", ofType: "bundle")
#endif

    internal static func systemVersionGreaterThanOrEqualTo(_ version: String) -> Bool {
        return
            UIDevice.current.systemVersion.compare(version, options: String.CompareOptions.numeric) != .orderedAscending
    }
}
