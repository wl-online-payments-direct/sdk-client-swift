//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation
import UIKit

public class SDKConstants {

    public static let kSDKLocalizable = "OPSDKLocalizable"
    public static let kImageMapping = "kImageMapping"
    public static let kImageMappingInitialized = "kImageMappingInitialized"
    public static let kIINMapping = "kIINMapping"

    public static let kApplePayIdentifier = "302"
    public static let kGooglePayIdentifier = "320"

    public static let kApiVersion = "client/v1"
    public static let kSDKBundleIdentifier = "org.cocoapods.OnlinePaymentsKit"
    public static var kSDKBundlePath = Bundle(identifier: SDKConstants.kSDKBundleIdentifier)?.path(forResource: "OnlinePaymentsKit", ofType: "bundle")

    public static func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: String) -> Bool {
        return UIDevice.current.systemVersion.compare(v, options: String.CompareOptions.numeric) != .orderedAscending
    }

}
