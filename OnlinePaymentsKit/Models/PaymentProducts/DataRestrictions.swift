//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPDataRestrictions)
public class DataRestrictions: NSObject, ResponseObjectSerializable {

    @objc public var isRequired = false
    @objc public var validators = Validators()

    @objc public override init() {}

    @objc required public init(json: [String: Any]) {
        if let input = json["isRequired"] as? Bool {
            isRequired = input
        }
        if let input = json["validators"] as? [String: Any] {
            if let _ = input.index(forKey: "luhn") {
                let validator = ValidatorLuhn()
                validators.validators.append(validator)
            }
            if let _ = input.index(forKey: "expirationDate") {
                let validator = ValidatorExpirationDate()
                validators.validators.append(validator)
            }
            if let range = input["range"] as? [String: Any] {
                let validator = ValidatorRange(json: range)
                validators.validators.append(validator)
            }
            if let length = input["length"] as? [String: Any] {
                let validator = ValidatorLength(json: length)
                validators.validators.append(validator)
            }
            if let fixedList = input["fixedList"] as? [String: Any] {
                let validator = ValidatorFixedList(json: fixedList)
                validators.validators.append(validator)
            }
            if let _ = input.index(forKey: "emailAddress") {
                let validator = ValidatorEmailAddress()
                validators.validators.append(validator)
            }
            if let regularExpression = input["regularExpression"] as? [String: Any],
                let validator = ValidatorRegularExpression(json: regularExpression) {
                validators.validators.append(validator)
            }
            if ((input["termsAndConditions"] as? [String: Any]) != nil) {
                let validator = ValidatorTermsAndConditions()
                validators.validators.append(validator)
            }
            if ((input["iban"] as? [String: Any]) != nil) {
                let validator = ValidatorIBAN()
                validators.validators.append(validator)
            }
        }
    }

}
