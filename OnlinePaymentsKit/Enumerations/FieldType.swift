//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPType)
public enum FieldType: Int {
    @objc(OPString) case string
    @objc(OPInteger) case integer
    @objc(OPExpirationDate) case expirationDate
    @objc(OPNumericString) case numericString
    @objc(OPBooleanString) case boolString
    @objc(OPDateString) case dateString
}
