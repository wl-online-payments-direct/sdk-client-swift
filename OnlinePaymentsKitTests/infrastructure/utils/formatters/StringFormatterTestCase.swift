/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import XCTest

@testable import OnlinePaymentsKit

class StringFormatterTestCase: XCTestCase {

    let stringFormatter = StringFormatter()

    func testFormatStringNumbers() {
        let mask = "{{99}} {{99}} {{99}} {{99}} {{99}}"
        var output = stringFormatter.formatString(string: "1234567890", mask: mask)
        XCTAssertEqual(output, "12 34 56 78 90", "Masking with numeric characters has failed")

        output = stringFormatter.formatString(string: "12345678", mask: mask)
        XCTAssertEqual(output, "12 34 56 78 ", "Masking should add trailing space when necessary")
    }

    func testFormatStringWildcards() {
        let input = "!!!!!!!!!!"
        let mask = "{{**}} {{**}} {{**}} {{**}} {{**}}"
        let output = stringFormatter.formatString(string: input, mask: mask)
        let expectedOutput = "!! !! !! !! !!"

        XCTAssertEqual(output, expectedOutput, "Masking with wildcards has failed")
    }

    func testFormatStringAlpha() {
        let input = "abcdefghij"
        let mask = "{{aa}} {{aa}} {{aa}} {{aa}} {{aa}}"
        let output = stringFormatter.formatString(string: input, mask: mask)
        let expectedOutput = "ab cd ef gh ij"

        XCTAssertEqual(output, expectedOutput, "Masking with alphabetic characters has failed")
    }

    func testFormStringWithCursorPosition() {
        let input = "abcdefghij"
        var cursorPosition = 10
        let mask = "{{aa}} {{aa}} {{aa}} {{aa}} {{aa}}"
        let output = stringFormatter.formatString(string: input, mask: mask, cursorPosition: &cursorPosition)
        let expectedOutput = "ab cd ef gh ij"

        XCTAssertEqual(output, expectedOutput, "Masking with cursor position has failed")
    }

    func testUnformatString() {
        let input = "12 34 56 78 90"
        let mask = "{{99}} {{99}} {{99}} {{99}} {{99}}"
        let output = stringFormatter.unformatString(string: input, mask: mask)
        let expectedOutput = "1234567890"
        XCTAssertEqual(output, expectedOutput, "Unmasking a string has failed")
    }

    func testRelaxMask() {
        let input = "{{9999}}/{{aaaa}}+{{****}}"
        let output = stringFormatter.relaxMask(mask: input)
        let expectedOutput = "{{****}}/{{****}}+{{****}}"

        XCTAssertEqual(output, expectedOutput, "Relaxing a mask has failed")
    }

}
