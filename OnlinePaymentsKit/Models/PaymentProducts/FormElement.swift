//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPFormElement)
public class FormElement: NSObject, ResponseObjectSerializable {
    @objc public var type: FormElementType
    @objc public var valueMapping = [ValueMappingItem]()

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
}
