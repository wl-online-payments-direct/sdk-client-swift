//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@available(
    *,
    deprecated,
    message: "In a future release, this class will be removed since it is not returned from the API."
)
@objc(OPDisplayElement)
public class DisplayElement: NSObject, Codable, ResponseObjectSerializable {

    @objc(identifier) public var id: String
    @objc public var type: DisplayElementType
    @objc public var value: String

    @objc init(id: String, type: DisplayElementType, value: String) {
        self.id = id
        self.type = type
        self.value = value
    }

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    @objc public required init?(json: [String: Any]) {

        guard let id = json["id"]  as? String else {
            return nil
        }

        guard let value = json["value"] as? String else {
            return nil
        }

        let type = DisplayElementTypeEnumHandler().displayElementTypeFor(type: json["type"] as? String ?? "")

        self.id = id
        self.value = value
        self.type = type
    }

    private enum CodingKeys: String, CodingKey {
        case id, type, value
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)

        let typeAsString = try? container.decodeIfPresent(String.self, forKey: .type)
        self.type = DisplayElementTypeEnumHandler().displayElementTypeFor(type: typeAsString ?? "")

        self.value = try container.decode(String.self, forKey: .value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id, forKey: .id)
        try? container.encode(type.text(), forKey: .type)
        try? container.encode(value, forKey: .value)
    }
}
