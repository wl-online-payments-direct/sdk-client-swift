//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPStringFormatter)
public class StringFormatter: NSObject {
    @objc public var decimalRegex: NSRegularExpression
    @objc public var lowerAlphaRegex: NSRegularExpression
    @objc public var upperAlphaRegex: NSRegularExpression

    @objc public override init() {
        decimalRegex = try! NSRegularExpression(pattern: "[0-9]")
        lowerAlphaRegex = try! NSRegularExpression(pattern: "[a-z]")
        upperAlphaRegex = try! NSRegularExpression(pattern: "[A-Z]")
    }

    @objc public func formatString(string: String, mask: String) -> String {
        var cursorPosition = 0
        return formatString(string: string, mask: mask, cursorPosition: &cursorPosition)
    }

    @objc(formatString:withMask:cursorPosition:)
    public func formatString(string: String, mask: String, cursorPosition: UnsafeMutablePointer<NSInteger>) -> String {
        let matches = parts(ofMask: mask)
        var copyFromMask = true
        var appendRestOfMask = true
        var stringIndex = 0
        var result = ""

        for match in matches {
            let matchString = processMatch(match: match, string: string, stringIndex: &stringIndex, mask: mask, copyFromMask: &copyFromMask, appendRestOfMask: &appendRestOfMask, cursorPosition: &cursorPosition.pointee)
            result = result.appending(matchString)
        }

        return result
    }

    @objc(unformatString:withMask:)
    public func unformatString(string: String, mask: String) -> String {
        let maskedString = formatString(string: string, mask: mask)
        let matches = parts(ofMask: mask)
        var result = ""
        var skip = true
        var index = 0

        for match in matches {
            if match == "{{" {
                skip = false
            } else if match == "}}" {
                skip = true
            } else {
                let maxLength = maskedString.count - index
                let length = min(maxLength, match.count)
                if !skip {
                    let endIndex = index + length
                    let maskedStringFragment = maskedString[index..<endIndex]
                    result = result.appending(maskedStringFragment)
                }
                index += length
            }
        }

        return result
    }

    @objc public func processMatch(match: String, string: String, stringIndex: UnsafeMutablePointer<Int>, mask: String, copyFromMask: UnsafeMutablePointer<Bool>, appendRestOfMask: UnsafeMutablePointer<Bool>, cursorPosition: UnsafeMutablePointer<Int>) -> String {
        var result = ""

        if match.isEqual("{{") {
            copyFromMask.pointee = false
        } else if match.isEqual("}}") {
            copyFromMask.pointee = true
        } else {
            var maskIndex = 0

            while stringIndex.pointee < string.count && maskIndex < match.count {
                let stringChar = string[stringIndex.pointee..<(stringIndex.pointee + 1)]
                let maskChar = match[maskIndex..<(maskIndex + 1)]
                if copyFromMask.pointee {
                    result = result.appending(maskChar)
                    if stringChar.isEqual(maskChar) {
                        stringIndex.pointee += 1
                    } else {
                        if cursorPosition.pointee >= stringIndex.pointee {
                            cursorPosition.pointee += 1
                        }
                    }
                    maskIndex += 1
                } else {
                    let range = NSRange(location: 0, length: 1)
                    if maskChar.isEqual("9") && decimalRegex.numberOfMatches(in: stringChar, range: range) > 0 {
                        result = result.appending(stringChar)
                        maskIndex += 1
                    } else if maskChar.isEqual("a") && lowerAlphaRegex.numberOfMatches(in: stringChar, range: range) > 0 {
                        result = result.appending(stringChar)
                        maskIndex += 1
                    } else if maskChar.isEqual("A") && upperAlphaRegex.numberOfMatches(in: stringChar, range: range) > 0 {
                        result = result.appending(stringChar)
                        maskIndex += 1
                    } else if maskChar.isEqual("*") {
                        result = result.appending(stringChar)
                        maskIndex += 1
                    }

                    stringIndex.pointee += 1
                }
            }

            if appendRestOfMask.pointee {
                if maskIndex < match.count {
                    if copyFromMask.pointee {
                        let remainingLength = match.count - maskIndex
                        let endIndex = maskIndex+remainingLength
                        result = result.appending(match[maskIndex..<endIndex])

                        if cursorPosition.pointee >= stringIndex.pointee {
                            cursorPosition.pointee += remainingLength
                        }
                    }

                    appendRestOfMask.pointee = false
                }
            }
        }

        return result
    }

    func parts(ofMask mask: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: "\\{\\{|\\}\\}|([^\\{\\}]|\\{(?!\\{)|\\}(?!\\}))*")
        let results = regex.matches(in: mask, range: NSRange(location: 0, length: mask.count))

        return results.map { (mask as NSString).substring(with: $0.range) }
    }

    @objc public func relaxMask(mask: String) -> String {
        let matches = parts(ofMask: mask)
        var relaxedMask = mask
        var replaceCharacters = false
        var maskIndex = 0

        for match in matches {
            if match.isEqual("{{") {
                replaceCharacters = true
                maskIndex = maskIndex + 2
            } else if match.isEqual("}}") {
                replaceCharacters = false
                maskIndex = maskIndex + 2
            } else {
                var length = match.count
                while length > 0 {
                    if replaceCharacters {
                        let startIndex = relaxedMask.index(relaxedMask.startIndex, offsetBy: maskIndex)
                        let endIndex = relaxedMask.index(after: startIndex)
                        relaxedMask = relaxedMask.replacingCharacters(in: startIndex..<endIndex, with: "*")
                    }
                    maskIndex += 1
                    length -= 1
                }
            }
        }

        return relaxedMask
    }

}
