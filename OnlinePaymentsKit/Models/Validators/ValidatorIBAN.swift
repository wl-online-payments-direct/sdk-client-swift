//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidatorIBAN)
public class ValidatorIBAN: Validator {
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
            let endIndex = remainder.index(remainder.startIndex, offsetBy: min(9, remainder.count), limitedBy: remainder.endIndex)!
            let currentChunk = remainder[remainder.startIndex ..< endIndex]
            let currentInt = Int(currentChunk)
            let currentResult = currentInt! % modulo
            remainder = String(currentResult) + remainder.dropFirst(9)
        } while remainder.count > 2
        return (Int(remainder)!) % modulo
    }
    @objc public override func validate(value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)
        let strippedText = value.components(separatedBy: .whitespacesAndNewlines).joined().uppercased()
        do {
            let formatRegex = try NSRegularExpression(pattern: "^[A-Z]{2}[0-9]{2}[A-Z0-9]{4}[0-9]{7}([A-Z0-9]?){0,16}$")
            let numberOfMatches = formatRegex.numberOfMatches(in: strippedText, range: NSRange(location: 0, length: strippedText.count))
            if numberOfMatches == 1 {
                let endIndex = strippedText.index(strippedText.startIndex, offsetBy: min(4, strippedText.count), limitedBy: strippedText.endIndex)!
                let prefix = strippedText[strippedText.startIndex ..< endIndex]
                let numericString = (strippedText.dropFirst(4) + prefix).map { (c: Character) in
                    return  String(charToIndex(mychar: c)!)
                }.joined()
                if modulo(numericString: numericString, modulo: 97) == 1 {
                    // Success
                    return
                }
            }
        } catch {
        }
        errors.append(ValidationErrorIBAN())
    }
}
