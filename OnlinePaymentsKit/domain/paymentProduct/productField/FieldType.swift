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

@objc(OPType) public enum FieldType: Int {
    @objc(OPString) case string
    @objc(OPInteger) case integer
    @objc(OPExpirationDate) case expirationDate
    @objc(OPNumericString) case numericString
    @objc(OPBooleanString) case boolString
    @objc(OPDateString) case dateString
}
