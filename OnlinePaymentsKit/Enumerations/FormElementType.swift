//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//
import Foundation

@objc(OPFormElementType)
public enum FormElementType: Int {
    @objc(OPTextType) case textType
    @objc(OPListType) case listType
    @objc(OPCurrencyType)case currencyType
    @objc(OPBoolType) case boolType
    @objc(OPDateType) case dateType
}
