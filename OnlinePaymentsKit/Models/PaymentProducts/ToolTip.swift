//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2025 Global Collect Services. All rights reserved.
// 

import UIKit

@objc(OPTooltip)
public class ToolTip: NSObject, Codable {

    @objc public var label: String?

    private enum CodingKeys: String, CodingKey {
        case image, label
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.label = try? container.decodeIfPresent(String.self, forKey: .label)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(label, forKey: .label)
    }
}
