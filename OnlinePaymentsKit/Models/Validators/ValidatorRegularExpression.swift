//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorRegularExpression: Validator, ResponseObjectSerializable {

    public var regularExpression: NSRegularExpression

    public init(regularExpression: NSRegularExpression) {
        self.regularExpression = regularExpression
    }

    public required init?(json: [String: Any]) {
        guard let input = json["regularExpression"] as? String,
            let regularExpression = try? NSRegularExpression(pattern: input) else {
            Macros.DLog(message: "Expression: \(json["regularExpression"]!) is invalid")
            return nil
        }

        self.regularExpression = regularExpression
    }

    public override func validate(value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)

        let numberOfMatches = regularExpression.numberOfMatches(in: value, range: NSRange(location: 0, length: value.count))
        if numberOfMatches != 1 {
            let error = ValidationErrorRegularExpression()
            errors.append(error)
        }
    }
}
