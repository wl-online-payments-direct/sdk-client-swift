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

@objc(OPAccountOnFileAttribute) public class AccountOnFileAttribute: NSObject {

    @objc public var key: String
    @objc public var value: String?
    @objc public var status: AccountOnFileAttributeStatus = .readOnly

    internal init(
        key: String,
        value: String?,
        status: AccountOnFileAttributeStatus
    ) {
        self.key = key
        self.value = value
        self.status = status

        super.init()
    }

    public func isEditingAllowed() -> Bool {
        status != .readOnly
    }
}
