//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import UIKit

@objc(OPTooltip)
public class ToolTip: NSObject, ResponseObjectSerializable {

    @objc public var imagePath: String?
    @objc public var image: UIImage?
    @objc public var label: String?

    @objc required public init(json: [String: Any]) {
        imagePath = json["image"] as? String
        if let input = json["label"] as? String {
            label = input
        }
    }
}
