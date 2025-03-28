//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidatorIBAN)
public class ValidatorIBAN: Validator, ValidationRule {

    internal override init() {
        super.init(messageId: "iban", validationType: .iban)
    }

    // periphery:ignore:parameters decoder
    public required init(from decoder: Decoder) throws {
        super.init(messageId: "iban", validationType: .iban)
    }

    private func charToIndex(mychar: Character) -> Int? {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        if let index = alphabet.firstIndex(of: mychar) {
            let numericValue = alphabet.distance(from: alphabet.startIndex, to: index) + 10
            return numericValue
        }

        if let myInt = Int(String(mychar)) {
            return myInt
        }

        return nil
    }

    private func modulo(numericString: String, modulo: Int) -> Int {
        var remainder = numericString
        repeat {
            let endIndex =
                remainder.index(
                    remainder.startIndex,
                    offsetBy: min(9, remainder.count),
                    limitedBy: remainder.endIndex
                )!
            let currentChunk = remainder[remainder.startIndex ..< endIndex]
            let currentInt = Int(currentChunk)
            let currentResult = currentInt! % modulo
            remainder = String(currentResult) + remainder.dropFirst(9)
        } while remainder.count > 2

        return (Int(remainder)!) % modulo
    }

    @objc public func validate(field fieldId: String, in request: PaymentRequest) -> Bool {
        guard let fieldValue = request.getValue(forField: fieldId) else {
            return false
        }

        return validate(value: fieldValue, for: fieldId)
    }

    @objc public func validate(value: String) -> Bool {
        validate(value: value, for: nil)
    }

    internal override func validate(value: String, for fieldId: String?) -> Bool {
        self.clearErrors()

        let strippedText = value.components(separatedBy: .whitespacesAndNewlines).joined().uppercased()

        guard let formatRegex =
                try? NSRegularExpression(pattern: "^[A-Z]{2}[0-9]{2}[A-Z0-9]{4}[0-9]{7}([A-Z0-9]?){0,16}$") else {
            return false
        }

        if numberOfMatches(regex: formatRegex, text: strippedText) == 1 &&
           modulo(numericString: numericString(of: strippedText), modulo: 97) == 1 {
            // Success
            return true
        }

        let error = ValidationErrorIBAN(errorMessage: self.messageId, paymentProductFieldId: fieldId, rule: self)
        errors.append(error)

        return false
    }

    private func numberOfMatches(regex: NSRegularExpression, text: String) -> Int {
        return regex.numberOfMatches(in: text, range: NSRange(location: 0, length: text.count))
    }

    private func numericString(of text: String) -> String {
        let endIndex = text.index(text.startIndex, offsetBy: min(4, text.count), limitedBy: text.endIndex)!
        let prefix = text[text.startIndex ..< endIndex]
        let numericString = (text.dropFirst(4) + prefix).map { (character: Character) in
            return String(charToIndex(mychar: character)!)
        }.joined()

        return numericString
    }
}
