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

@objc(OPFormElement) public class FormElement: NSObject {
    @objc public var type: FormElementType = .textType

    internal init(type: FormElementType) {
        self.type = type
        super.init()
    }
}
