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

extension String {

    subscript(index: Int) -> String {
        return self[index..<index + 1]
    }

    func substring(from minIndex: Int) -> String {
        return self[min(minIndex, count)..<count]
    }

    func substring(to maxIndex: Int) -> String {
        return self[0..<max(0, maxIndex)]
    }

    subscript(range: Range<Int>) -> String {
        let range = Range(
            uncheckedBounds: (
                lower: max(0, min(count, range.lowerBound)),
                upper: min(count, max(0, range.upperBound))
            )
        )
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start..<end])
    }

    func base64URLDecode() -> Data {
        let underscoreReplaced = self.replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let modulo = self.count % 4
        var paddingAdded = underscoreReplaced

        if modulo == 2 {
            paddingAdded += "=="
        } else if modulo == 3 {
            paddingAdded += "="
        }

        return self.decode(paddingAdded)
    }

    func decode(_ string: String? = nil) -> Data {
        if let str = string {
            return Data(base64Encoded: str)!
        }
        return Data(base64Encoded: self)!
    }

    mutating func appendIf(where predicate: (String) -> Bool, text: String) {
        if predicate(self) {
            append(text)
        }
    }
}
