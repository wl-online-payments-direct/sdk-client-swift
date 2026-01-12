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

@objc(OPPreferredInputType) public enum PreferredInputType: Int {
    @objc(OPStringKeyboard) case stringKeyboard
    @objc(OPIntegerKeyboard) case integerKeyboard
    @objc(OPEmailAddressKeyboard) case emailAddressKeyboard
    @objc(OPPhoneNumberKeyboard) case phoneNumberKeyboard
    @objc(OPDateKeyboard) case dateKeyboard
}
