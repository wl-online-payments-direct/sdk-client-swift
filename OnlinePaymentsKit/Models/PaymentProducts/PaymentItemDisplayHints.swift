//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import UIKit

@objc(OPPaymentItemDisplayHints)
public class PaymentItemDisplayHints: NSObject {

    @objc public var displayOrder: Int
    @objc public var label: String?
    @objc public var logoPath: String
    @objc public var logoImage: UIImage?

    @objc required public init?(json: [String: Any]) {
        if let input = json["label"] as? String {
            label = input
        }
        
        guard let logoPath = json["logo"] as? String else {
            return nil
        }
        self.logoPath = logoPath

        guard let displayOrder = json["displayOrder"] as? Int else {
            return nil
        }
        self.displayOrder = displayOrder
    }
    
    internal override init() {
        self.displayOrder = 0
        self.logoPath = ""
        super.init()
    }

}
