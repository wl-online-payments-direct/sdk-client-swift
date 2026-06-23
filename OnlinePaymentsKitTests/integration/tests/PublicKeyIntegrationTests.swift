/*
 * Do not remove or alter the notices in this preamble.
 *
 * This software is owned by Worldline and may not be be altered, copied, reproduced, republished, uploaded, posted, transmitted or distributed in any way, without the prior written consent of Worldline.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import XCTest

@testable import OnlinePaymentsKit

/// Integration tests for retrieving the public key.
class PublicKeyIntegrationTests: BaseIntegrationTest {

    func testGetPublicKey_shouldReturnPublicKeyWithNonEmptyFields() {
        let expectation = expectation(description: "Get public key")

        sdk.publicKey(
            success: { publicKeyResponse in
                XCTAssertFalse(
                    publicKeyResponse.keyId.isEmpty,
                    "Public key response should have a non-empty keyId"
                )

                XCTAssertFalse(
                    publicKeyResponse.publicKey.isEmpty,
                    "Public key response should have a non-empty publicKey"
                )

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetPublicKey_calledTwice_shouldUseCacheOnSecondCall() {
        let firstExpectation = expectation(description: "First public key call")
        let secondExpectation = expectation(description: "Second public key call")

        sdk.publicKey(
            success: { firstResult in
                firstExpectation.fulfill()

                self.sdk.publicKey(
                    success: { secondResult in
                        XCTAssertEqual(
                            firstResult.keyId,
                            secondResult.keyId,
                            "Cached result should have the same keyId"
                        )

                        XCTAssertEqual(
                            firstResult.publicKey,
                            secondResult.publicKey,
                            "Cached result should have the same publicKey"
                        )

                        secondExpectation.fulfill()
                    },
                    failure: { error in
                        XCTFail("Second call should not fail: \(error)")
                        secondExpectation.fulfill()
                    }
                )
            },
            failure: { error in
                XCTFail("First call should not fail: \(error)")
                firstExpectation.fulfill()
                secondExpectation.fulfill()
            }
        )

        waitForExpectations(timeout: 15.0)
    }
}
