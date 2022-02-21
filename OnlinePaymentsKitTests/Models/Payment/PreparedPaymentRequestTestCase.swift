//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class PreparedPaymentRequestTestCase: XCTestCase {

    func testPreparedPaymentRequest() {
        let encrypted = "encrypted"
        let meta = "Meta info"
        let request = PreparedPaymentRequest(encryptedFields: encrypted, encodedClientMetaInfo: meta)
        XCTAssertTrue(request.encodedClientMetaInfo == meta, "Meta info was incorrect.")
        XCTAssertTrue(request.encryptedFields == encrypted, "Encrypted was incorrect.")

        request.encryptedFields = "encrypted1"
        XCTAssertTrue(request.encryptedFields == "encrypted1", "Encrypted was incorrect.")
    }
}
