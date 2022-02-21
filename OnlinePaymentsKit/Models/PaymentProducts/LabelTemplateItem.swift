//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

public class LabelTemplateItem: ResponseObjectSerializable {

    public var attributeKey: String
    public var mask: String?

    required public init?(json: [String: Any]) {
        guard let attributeKey = json["attributeKey"] as? String else {
            return nil
        }
        self.attributeKey = attributeKey

        mask = json["mask"] as? String
    }

}
