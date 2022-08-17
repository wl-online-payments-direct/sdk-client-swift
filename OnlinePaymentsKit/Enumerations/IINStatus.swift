//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 
import Foundation

@objc(OPIINStatus)
public enum IINStatus: Int {
    @objc(OPSupported) case supported
    @available(*, deprecated, message: "In a next release, this status will be removed.")
    @objc(OPUnsupported) case unsupported
    @objc(OPUnknown) case unknown
    @objc(OPNotEnoughDigits) case notEnoughDigits
    @available(*, deprecated, message: "In a next release, this status will be removed.")
    @objc(OPPending) case pending
    @objc(OPExistingButNotAllowed) case existingButNotAllowed
}
