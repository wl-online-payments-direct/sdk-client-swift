//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 31/07/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPSurchargeResult)
public enum SurchargeResult: Int, Codable {
    // swiftlint:disable identifier_name
    @objc(OPOk) case ok
    // swiftlint:enable identifier_name
    @objc(OPNoSurcharge) case noSurcharge
}
