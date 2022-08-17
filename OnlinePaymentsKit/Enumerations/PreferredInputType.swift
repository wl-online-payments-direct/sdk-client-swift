//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 
import Foundation

@objc(OPPreferredInputType)
public enum PreferredInputType: Int {
    @objc(OPStringKeyboard) case stringKeyboard
    @objc(OPIntegerKeyboard) case integerKeyboard
    @objc(OPEmailAddressKeyboard) case emailAddressKeyboard
    @objc(OPPhoneNumberKeyboard) case phoneNumberKeyboard
    @objc(OPDateKeyboard) case dateKeyboard
    @objc(OPNoKeyboard) case noKeyboard
}
