/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation
import UIKit

@objc(OPSupportedProductsUtil)

public class SupportedProductsUtil: NSObject {
    internal static let kApplePayIdentifier = 302
    internal static let kMaestroIdentifier = 117
    internal static let kIntersolveIdentifier = 5700
    internal static let kSodexoSportCultureIdentifier = 5772
    internal static let kVVVGiftCardIdentifier = 5784

    internal static let sdkUnsupportedProducts: [Int] = [
        kMaestroIdentifier,
        kIntersolveIdentifier,
        kSodexoSportCultureIdentifier,
        kVVVGiftCardIdentifier,
    ]

    internal static func isSupportedInSdk(_ productId: Int?) -> Bool {
        guard let productId = productId else {
            return false
        }
        return !sdkUnsupportedProducts.contains(productId)
    }

    internal static func get404Error() -> ErrorResponse {
        ErrorResponse(
            errorId: "48b78d2d-1b35-4f8b-92cb-57cc2638e901",
            errors: [
                ApiErrorItem(
                    errorCode: "1007",
                    category: nil,
                    httpStatusCode: 404,
                    id: nil,
                    message: "UNKNOWN_PRODUCT_ID",
                    propertyName: "productId",
                    retriable: false
                )
            ]
        )
    }

    #if SWIFT_PACKAGE
        @objc(kOPSDKBundlePath)
        public static var kSDKBundlePath = Bundle.module.path(forResource: "OnlinePaymentsKit", ofType: "bundle")
    #elseif COCOAPODS
        private static let kSDKBundleIdentifier = "org.cocoapods.OnlinePaymentsKit"
        @objc(kOPSDKBundlePath)
        public static var kSDKBundlePath =
            Bundle(identifier: SDKConstants.kSDKBundleIdentifier)?.path(
                forResource: "OnlinePaymentsKit",
                ofType: "bundle"
            )
    #else
        private static let kSDKBundleIdentifier = "com.onlinepayments.OnlinePaymentsKit"
        @objc(kOPSDKBundlePath)
        public static var kSDKBundlePath =
            Bundle(identifier: SupportedProductsUtil.kSDKBundleIdentifier)?.path(
                forResource: "OnlinePaymentsKit",
                ofType: "bundle"
            )
    #endif

    internal static func systemVersionGreaterThanOrEqualTo(_ version: String) -> Bool {
        return
            UIDevice.current.systemVersion.compare(version, options: String.CompareOptions.numeric) != .orderedAscending
    }
}
