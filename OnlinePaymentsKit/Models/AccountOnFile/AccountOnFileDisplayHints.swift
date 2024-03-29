//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPAccountOnFileDisplayHints)
public class AccountOnFileDisplayHints: NSObject, Codable {

    @objc public var labelTemplate: LabelTemplate = LabelTemplate()

    internal override init() {
        super.init()
    }

    private enum CodingKeys: String, CodingKey {
        case labelTemplate
    }

    public required init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           let labelTemplates = try? container.decodeIfPresent([LabelTemplateItem].self, forKey: .labelTemplate) {
            for labelTemplate in labelTemplates {
                self.labelTemplate.labelTemplateItems.append(labelTemplate)
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(labelTemplate.labelTemplateItems, forKey: .labelTemplate)
    }
}
