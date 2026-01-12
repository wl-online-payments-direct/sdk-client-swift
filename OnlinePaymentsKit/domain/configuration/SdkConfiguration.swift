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

@objc(OPSdkConfiguration) public class SdkConfiguration: NSObject {
    public let appIdentifier: String?
    public let loggingEnabled: Bool

    public init(
        appIdentifier: String?,
        loggingEnabled: Bool = false,
    ) {
        self.appIdentifier = appIdentifier
        self.loggingEnabled = loggingEnabled
    }
}
