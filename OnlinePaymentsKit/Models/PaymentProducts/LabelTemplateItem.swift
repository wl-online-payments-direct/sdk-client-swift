//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPLabelTemplateItem)
public class LabelTemplateItem: NSObject, Codable {

    @objc public var attributeKey: String
    @objc public var mask: String?

}
