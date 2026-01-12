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

/// Immutable session configuration data.
///
/// **Note:** This is intentionally a class (not a struct) to maintain Objective-C compatibility
/// via the `@objc` annotation. All properties are immutable (`let`) to provide value semantics
/// despite being a reference type.
@objc(OPSessionData) public class SessionData: NSObject {
    public let clientSessionId: String
    public let customerId: String
    public let clientApiUrl: String
    public let assetUrl: String

    public init(
        clientSessionId: String,
        customerId: String,
        clientApiUrl: String,
        assetUrl: String
    ) {
        self.clientSessionId = clientSessionId
        self.customerId = customerId
        self.clientApiUrl = clientApiUrl
        self.assetUrl = assetUrl
    }
}
