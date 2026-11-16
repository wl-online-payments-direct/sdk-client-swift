/*
 * Do not remove or alter the notices in this preamble.
 *
 * This software is owned by Worldline and may not be be altered, copied, reproduced, republished, uploaded, posted, transmitted or distributed in any way, without the prior written consent of Worldline.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation

/// Optional settings of the `OnlinePaymentsSdk`.
@objc(OPSdkConfiguration) public class SdkConfiguration: NSObject {
    /// Identifies your app (for example `My App/v2.0.4`) in the client meta information that the SDK sends with
    /// its requests. `nil` or an empty string is sent as `UNKNOWN`.
    public let appIdentifier: String?

    /// When `true`, the SDK prints every request and response of its client API calls to the console, in all build
    /// configurations: the URL, the headers including the client session id, POST bodies (which can contain
    /// card digits) and response bodies. The setting applies to the `OnlinePaymentsSdk` instance it is passed to.
    /// Keep it `false` in production.
    public let loggingEnabled: Bool

    public init(
        appIdentifier: String?,
        loggingEnabled: Bool = false,
    ) {
        self.appIdentifier = appIdentifier
        self.loggingEnabled = loggingEnabled
    }
}
