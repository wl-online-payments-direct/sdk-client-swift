//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPIINDetail)
public class IINDetail: NSObject, ResponseObjectSerializable {
    @objc public var paymentProductId: String
    @objc(isAllowedInContext) public var allowedInContext: Bool = false
    //public var allowedInContext: Bool = false

    @objc required public init?(json: [String: Any]) {
        if let input = json["paymentProductId"] as? Int {
            paymentProductId = "\(input)"
        } else {
            return nil
        }
        if let input = json["isAllowedInContext"] as? Bool {
            allowedInContext = input
        }
    }

    @objc public init(paymentProductId: String, allowedInContext: Bool) {
        self.paymentProductId = paymentProductId
        self.allowedInContext = allowedInContext
    }
}
