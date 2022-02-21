//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

public class LabelTemplate {

    public var labelTemplateItems = [LabelTemplateItem]()

    public func mask(forAttributeKey key: String) -> String? {
        for labelTemplateItem in labelTemplateItems where labelTemplateItem.attributeKey.isEqual(key) {
            return labelTemplateItem.mask
        }
        return nil
    }

}
