//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import UIKit

public class ToolTip: ResponseObjectSerializable {

    public var imagePath: String?
    public var image: UIImage?
    public var label: String?

    required public init(json: [String: Any]) {
        imagePath = json["image"] as? String
        if let input = json["label"] as? String {
            label = input
        }
    }
}
