//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPFormElement)
public class FormElement: NSObject, Codable {
    @objc public var type: FormElementType = .textType

    private enum CodingKeys: String, CodingKey {
        case type
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        super.init()

        let formElementTypeAsString = try? container.decodeIfPresent(String.self, forKey: .type)
        self.type = self.getFormElementType(type: formElementTypeAsString)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(getFormElementTypeString(type: type), forKey: .type)
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
            Logger.log("FormElementType type: \(type ?? "") is invalid")
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
