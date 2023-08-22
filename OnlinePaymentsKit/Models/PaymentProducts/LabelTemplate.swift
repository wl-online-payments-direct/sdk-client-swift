//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPLabelTemplate)
public class LabelTemplate: NSObject {

    @objc public var labelTemplateItems = [LabelTemplateItem]()

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    @objc public override init() {
        super.init()
    }

    @objc public func mask(forAttributeKey key: String) -> String? {
        for labelTemplateItem in labelTemplateItems where labelTemplateItem.attributeKey.isEqual(key) {
            return labelTemplateItem.mask
        }
        return nil
    }

}
