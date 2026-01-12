/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation

@objc(OPValidatorIBAN) public class ValidatorIBAN: NSObject, ValidationRule {
    @objc public let messageId: String = "iban"
    @objc public let type: ValidationType = .iban

    internal override init() {
        super.init()
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
            let endIndex = remainder.index(
                remainder.startIndex,
                offsetBy: min(9, remainder.count),
                limitedBy: remainder.endIndex
            )!
            let currentChunk = remainder[remainder.startIndex..<endIndex]
            let currentInt = Int(currentChunk)
            let currentResult = currentInt! % modulo
            remainder = String(currentResult) + remainder.dropFirst(9)
        } while remainder.count > 2

        return (Int(remainder)!) % modulo
    }

    @objc public func validate(value: String) -> RuleValidationResult {
        let errorMessage = "IBAN is not in the correct format."
        let strippedText = value.components(separatedBy: .whitespacesAndNewlines).joined().uppercased()

        guard
            let formatRegex = try? NSRegularExpression(
                pattern: "^[A-Z]{2}[0-9]{2}[A-Z0-9]{4}[0-9]{7}([A-Z0-9]?){0,16}$"
            )
        else {
            return RuleValidationResult(
                valid: false,
                message: errorMessage
            )
        }

        if numberOfMatches(regex: formatRegex, text: strippedText) == 1
            && modulo(numericString: numericString(of: strippedText), modulo: 97) == 1
        {
            // Success
            return RuleValidationResult(
                valid: true,
                message: ""
            )
        }

        return RuleValidationResult(
            valid: false,
            message: errorMessage
        )
    }

    private func numberOfMatches(regex: NSRegularExpression, text: String) -> Int {
        return regex.numberOfMatches(in: text, range: NSRange(location: 0, length: text.count))
    }

    private func numericString(of text: String) -> String {
        let endIndex = text.index(text.startIndex, offsetBy: min(4, text.count), limitedBy: text.endIndex)!
        let prefix = text[text.startIndex..<endIndex]
        let numericString = (text.dropFirst(4) + prefix).map {
            (character: Character) in
            return String(charToIndex(mychar: character)!)
        }.joined()

        return numericString
    }
}
