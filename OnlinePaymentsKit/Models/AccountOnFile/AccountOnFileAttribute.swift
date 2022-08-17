//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPAccountOnFileAttribute)
public class AccountOnFileAttribute: NSObject {

    @objc public var key: String
    @objc public var value: String?
    @objc public var status: AccountOnFileAttributeStatus
    @objc public var mustWriteReason: String?

    @objc required public init?(json: [String: Any]) {
        guard let key = json["key"] as? String else {
            return nil
        }
        self.key = key
        value = json["value"] as? String
        mustWriteReason = json["mustWriteReason"] as? String

        switch json["status"] as? String {
        case "READ_ONLY"?:
            status = .readOnly
        case "CAN_WRITE"?:
            status = .canWrite
        case "MUST_WRITE"?:
            status = .mustWrite
        default:
            Macros.DLog(message: "Status \(json["status"]!) in JSON fragment status is invalid")
            return nil
        }
    }

}
