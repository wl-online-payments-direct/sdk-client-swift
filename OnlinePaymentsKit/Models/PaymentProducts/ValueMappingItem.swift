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
@objc(OPValueMappingItem)
public class ValueMappingItem: NSObject, Codable, ResponseObjectSerializable {

    @objc public var displayName: String?
    @objc public var displayElements: [DisplayElement] = []
    @objc public var value: String

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    @objc required public init?(json: [String: Any]) {
        guard let value = json["value"] as? String else {
            return nil
        }

        self.value = value

        if let displayElements = json["displayElements"] as? [[String: Any]] {
            for element in displayElements {
                if let displayElement = DisplayElement(json: element) {
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

    private enum CodingKeys: String, CodingKey {
        case displayName, displayElements, value
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let displayName = try? container.decodeIfPresent(String.self, forKey: .displayName) {
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
        self.value = try container.decode(String.self, forKey: .value)
        if let displayElements = try? container.decodeIfPresent([DisplayElement].self, forKey: .displayElements) {
            for displayElement in displayElements {
                self.displayElements.append(displayElement)
            }
        }
    }
}
