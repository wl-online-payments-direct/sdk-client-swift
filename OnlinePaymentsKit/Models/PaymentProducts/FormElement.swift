//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPFormElement)
public class FormElement: NSObject, Codable, ResponseObjectSerializable {
    @objc public var type: FormElementType = .textType
    @available(
        *,
        deprecated,
         message: "In a future release, this property will be removed since it is not returned from the API."
    )
    @objc public var valueMapping = [ValueMappingItem]()

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    @objc required public init?(json: [String: Any]) {
        switch json["type"] as? String {
        case "text"?:
            type = .textType
        case "currency"?:
            type = .currencyType
        case "list"?:
            type = .listType
        case "date"?:
            type = .dateType
        case "boolean"?:
            type = .boolType
        default:
            Macros.DLog(message: "FormElementType type: \(json["type"]!) is invalid")
            return nil
        }

        if let input = json["valueMapping"] as? [[String: Any]] {
            for valueInput in input {
                if let item = ValueMappingItem(json: valueInput) {
                    valueMapping.append(item)
                }
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type, valueMapping
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let valueMapping = try? container.decodeIfPresent([ValueMappingItem].self, forKey: .valueMapping) {
            self.valueMapping = valueMapping
        }

        super.init()

        let formElementTypeAsString = try? container.decodeIfPresent(String.self, forKey: .type)
        self.type = self.getFormElementType(type: formElementTypeAsString)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(getFormElementTypeString(type: type), forKey: .type)
        try? container.encode(valueMapping, forKey: .valueMapping)
    }

    private func getFormElementType(type: String?) -> FormElementType {
        switch type {
        case "text":
            return FormElementType.textType
        case "list":
            return FormElementType.listType
        case "currency":
            return FormElementType.currencyType
        case "boolean":
            return FormElementType.boolType
        case "date":
            return FormElementType.dateType
        default:
            Macros.DLog(message: "FormElementType type: \(type ?? "") is invalid")
            return FormElementType.textType
        }
    }

    private func getFormElementTypeString(type: FormElementType) -> String {
        switch type {
        case FormElementType.textType:
            return "text"
        case FormElementType.listType:
            return "list"
        case FormElementType.currencyType:
            return "currency"
        case FormElementType.boolType:
            return "boolean"
        case FormElementType.dateType:
            return "date"
        }
    }
}
