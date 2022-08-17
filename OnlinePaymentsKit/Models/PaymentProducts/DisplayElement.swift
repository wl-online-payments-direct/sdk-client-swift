//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPDisplayElement)
public class DisplayElement: NSObject, ResponseObjectSerializable {

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

    @objc(identifier) public var id: String
    @objc public var type: DisplayElementType
    @objc public var value: String

    @objc init(id: String, type: DisplayElementType, value: String) {
        self.id = id
        self.type = type
        self.value = value
    }
}
