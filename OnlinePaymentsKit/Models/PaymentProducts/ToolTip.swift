//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import UIKit

@objc(OPTooltip)
public class ToolTip: NSObject, Codable, ResponseObjectSerializable {

    @available(
        *,
        deprecated,
        message: "In a future release, this property will be removed since it is not returned from the API."
    )
    @objc public var imagePath: String?
    @available(*, deprecated, message: "In a future release, this property will be removed.")
    @objc public var image: UIImage?
    @objc public var label: String?

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    @objc required public init(json: [String: Any]) {
        imagePath = json["image"] as? String
        if let input = json["label"] as? String {
            label = input
        }
    }

    private enum CodingKeys: String, CodingKey {
        case image, label
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.imagePath = try? container.decodeIfPresent(String.self, forKey: .image)
        self.label = try? container.decodeIfPresent(String.self, forKey: .label)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(imagePath, forKey: .image)
        try? container.encodeIfPresent(label, forKey: .label)
    }
}
