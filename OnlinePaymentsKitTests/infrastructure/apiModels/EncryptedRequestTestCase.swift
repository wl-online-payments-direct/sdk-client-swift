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

class EncryptedRequestTestCase: XCTestCase {

    func testEncryptRequest() {
        let encrypted = "encrypted"
        let meta = "Meta info"
        let request = EncryptedRequest(encryptedCustomerInput: encrypted, encodedClientMetaInfo: meta)
        XCTAssertTrue(request.encodedClientMetaInfo == meta, "Meta info was incorrect.")
        XCTAssertTrue(request.encryptedCustomerInput == encrypted, "Encrypted was incorrect.")

        request.encryptedCustomerInput = "encrypted1"
        XCTAssertTrue(request.encryptedCustomerInput == "encrypted1", "Encrypted was incorrect.")
    }
}
