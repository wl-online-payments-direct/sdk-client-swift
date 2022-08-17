//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValueMappingItem)
public class ValueMappingItem: NSObject, ResponseObjectSerializable {

    @objc public var displayName: String?
    @objc public var displayElements: [DisplayElement]
    @objc public var value: String

    @objc required public init?(json: [String: Any]) {
        guard let value = json["value"] as? String else {
            return nil
        }

        self.value = value
        self.displayElements = []

        if let displayElements = json["displayElements"] as? [[String: Any]] {
            for el in displayElements {
                if let displayElement = DisplayElement(json: el) {
                    self.displayElements.append(displayElement)
                }
            }
        }

        if let displayName = json["displayName"] as? String {
            self.displayName = displayName
            if self.displayElements.filter({ $0.id == "displayName" }).count == 0 && displayName != "" {
                let newElement = DisplayElement(id: "displayName", type: .string, value: displayName)
                self.displayElements.append(newElement)
            }
        } else {
            let displayNames = self.displayElements.filter { $0.id == "displayName" }
            if  displayNames.count > 0 {
                self.displayName = displayNames.first?.value
            }
        }
    }
}
