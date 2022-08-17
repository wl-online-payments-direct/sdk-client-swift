//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc public enum DisplayElementType: Int {
    @objc(OPDisplayElementTypeString) case string
    @objc(OPDisplayElementTypeInteger) case integer
    @objc(OPDisplayElementTypeCurrency) case currency
    @objc(OPDisplayElementTypePercentage) case percentage
    @objc(OPDisplayElementTypeURI) case uri
    
    func text() -> String {
        switch self {
        case .string:
            return "STRING"
        case .integer:
            return "INTEGER"
        case .currency:
            return "CURRENCY"
        case .percentage:
            return "PERCENTAGE"
        case .uri:
            return "URI"
        }
    }
}

@objc public class DisplayElementTypeEnumHandler: NSObject {
    @objc public func displayElementTypeFor(type: String) -> DisplayElementType {
        switch type {
            case "STRING":
                return DisplayElementType.string
            case "INTEGER":
                return DisplayElementType.integer
            case "CURRENCY":
                return DisplayElementType.currency
            case "PERCENTAGE":
                return DisplayElementType.percentage
            case "URI":
                return DisplayElementType.uri
            default:
                return DisplayElementType.string
        }
    }
    /// Objective-C compatible method to get a String value of DisplayElementType enum case
    @objc public func textFor(displayElementType: DisplayElementType) -> String {
        return displayElementType.text()
    }
}
