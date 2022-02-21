//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

public class IINDetail: ResponseObjectSerializable {
    public var paymentProductId: String
    public var allowedInContext: Bool = false

    required public init?(json: [String: Any]) {
        if let input = json["paymentProductId"] as? Int {
            paymentProductId = "\(input)"
        } else {
            return nil
        }
        if let input = json["isAllowedInContext"] as? Bool {
            allowedInContext = input
        }
    }

    public init(paymentProductId: String, allowedInContext: Bool) {
        self.paymentProductId = paymentProductId
        self.allowedInContext = allowedInContext
    }
}
