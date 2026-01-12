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

@objc(OPFormElementType) public enum FormElementType: Int {
    @objc(OPTextType) case textType
    @objc(OPListType) case listType
    @objc(OPCurrencyType) case currencyType
    @objc(OPBoolType) case boolType
    @objc(OPDateType) case dateType
}
