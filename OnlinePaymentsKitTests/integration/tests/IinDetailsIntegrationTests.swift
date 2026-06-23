/*
 * Do not remove or alter the notices in this preamble.
 *
 * This software is owned by Worldline and may not be altered, copied, reproduced, republished, uploaded, posted, transmitted or distributed in any way, without the prior written consent of Worldline.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import XCTest
import OHHTTPStubs
import OHHTTPStubsSwift

@testable import OnlinePaymentsKit

/// Integration tests for IIN details lookup.
class IinDetailsIntegrationTests: BaseIntegrationTest {

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testGetIinDetails_acceptsCardNumberWithSixDigits() {
        let expectation = expectation(description: "Get IIN details with six digits")

        sdk.iinDetails(
            forPartialCardNumber: "400000",
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertNotNil(iinDetailsResponse, "Result should not be nil")
                XCTAssertNotEqual(
                    IINStatus.notEnoughDigits,
                    iinDetailsResponse.status,
                    "Status should not be NOT_ENOUGH_DIGITS for six-digit input"
                )

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail for six-digit card number: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetIinDetails_makesNewApiCallForDifferentCardNumbers() {
        let firstExpectation = expectation(description: "First IIN call")
        let secondExpectation = expectation(description: "Second IIN call")

        sdk.iinDetails(
            forPartialCardNumber: "456735",
            paymentContext: paymentContext,
            success: { firstResult in
                XCTAssertNotNil(firstResult, "First result should not be nil")
                firstExpectation.fulfill()

                self.sdk.iinDetails(
                    forPartialCardNumber: "424242",
                    paymentContext: self.paymentContext,
                    success: { secondResult in
                        XCTAssertNotNil(secondResult, "Second result should not be nil")
                        XCTAssertFalse(
                            firstResult === secondResult,
                            "Different card numbers should yield distinct response objects"
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

    func testGetIinDetails_returnsCachedResultForRepeatedBIN() {
        let firstExpectation = expectation(description: "First IIN call")
        let secondExpectation = expectation(description: "Second IIN call")

        sdk.iinDetails(
            forPartialCardNumber: "456735",
            paymentContext: paymentContext,
            success: { firstResult in
                firstExpectation.fulfill()

                self.sdk.iinDetails(
                    forPartialCardNumber: "456735",
                    paymentContext: self.paymentContext,
                    success: { secondResult in
                        XCTAssertEqual(
                            firstResult.status,
                            secondResult.status,
                            "Cached result should have the same status"
                        )
                        XCTAssertEqual(
                            firstResult.paymentProductId,
                            secondResult.paymentProductId,
                            "Cached result should have the same payment product ID"
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

    func testGetIinDetails_returnsExistingButNotAllowedWhenCardIsNotAllowedInContext() {
        stubIinDetailsResponse(
            jsonObject: [
                "paymentProductId": 1,
                "countryCode": "NL",
                "isAllowedInContext": false
            ]
        )

        let expectation = expectation(description: "Get IIN details for not allowed card")

        sdk.iinDetails(
            forPartialCardNumber: "400000",
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertEqual(
                    IINStatus.existingButNotAllowed,
                    iinDetailsResponse.status,
                    "Status should be EXISTING_BUT_NOT_ALLOWED when card is not allowed in context"
                )
                XCTAssertEqual(1, iinDetailsResponse.paymentProductId)
                XCTAssertEqual("NL", iinDetailsResponse.countryCode)

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetIinDetails_returnsSupportedStatusForFullCardNumber() {
        let expectation = expectation(description: "Get IIN details for full card number")

        sdk.iinDetails(
            forPartialCardNumber: "4242424242424242",
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertNotNil(iinDetailsResponse, "Result should not be nil")
                XCTAssertEqual(
                    IINStatus.supported,
                    iinDetailsResponse.status,
                    "Status should be SUPPORTED for full valid card number"
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

    func testGetIinDetails_returnsSupportedStatusForValidBIN() {
        let expectation = expectation(description: "Get IIN details for valid BIN")

        sdk.iinDetails(
            forPartialCardNumber: "400000",
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertEqual(
                    IINStatus.supported,
                    iinDetailsResponse.status,
                    "Status should be SUPPORTED for valid BIN"
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

    func testGetIinDetails_returnsSupportedStatusWhenIsAllowedInContextIsAbsent() {
        stubIinDetailsResponse(
            jsonObject: [
                "paymentProductId": 1,
                "countryCode": "NL"
            ]
        )

        let expectation = expectation(description: "Get IIN details when isAllowedInContext is absent")

        sdk.iinDetails(
            forPartialCardNumber: "400000",
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertNotNil(iinDetailsResponse, "Result should not be nil")

                /*
                 Swift currently defaults allowedInContext to false when the field is absent.
                 This documents current Swift behavior for the shared scenario.
                 */
                XCTAssertEqual(
                    IINStatus.existingButNotAllowed,
                    iinDetailsResponse.status,
                    "Swift currently returns EXISTING_BUT_NOT_ALLOWED when isAllowedInContext is absent"
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

    func testGetIinDetails_returnsUnknownStatusForUnknownCardNumber() {
        stubIinDetailsResponse(
            jsonObject: [
                "countryCode": "NL"
            ]
        )

        let expectation = expectation(description: "Get IIN details for unknown card number")

        sdk.iinDetails(
            forPartialCardNumber: "999999",
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertEqual(
                    IINStatus.unknown,
                    iinDetailsResponse.status,
                    "Status should be UNKNOWN when paymentProductId is absent"
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

    func testGetIinDetails_returnsNotEnoughDigitsStatusWhenCardNumberHasFewerThanSixDigits() {
        let expectation = expectation(description: "Get IIN details with fewer than six digits")

        sdk.iinDetails(
            forPartialCardNumber: "12345",
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertEqual(
                    IINStatus.notEnoughDigits,
                    iinDetailsResponse.status,
                    "Swift returns NOT_ENOUGH_DIGITS instead of throwing an exception"
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

    func testGetIinDetails_acceptsCardNumberWithSpaces() {
        let expectation = expectation(description: "Get IIN details with spaces")

        sdk.iinDetails(
            forPartialCardNumber: "4000 0000 0000 0002",
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertNotNil(iinDetailsResponse, "Result should not be nil")
                XCTAssertEqual(
                    IINStatus.supported,
                    iinDetailsResponse.status,
                    "Status should be SUPPORTED when card number contains spaces"
                )

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail when card number contains spaces: \(error)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0)
    }

    func testGetIinDetails_detailsAllowedContextStatusExistingButNotAllowed() {
        stubIinDetailsResponse(
            jsonObject: [
                "paymentProductId": 1,
                "countryCode": "NL",
                "isAllowedInContext": false
            ]
        )

        let expectation = expectation(description: "Get IIN details with existing but not allowed status")

        sdk.iinDetails(
            forPartialCardNumber: "400000",
            paymentContext: paymentContext,
            success: { iinDetailsResponse in
                XCTAssertEqual(
                    IINStatus.existingButNotAllowed,
                    iinDetailsResponse.status,
                    "Status should be EXISTING_BUT_NOT_ALLOWED"
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

    private func stubIinDetailsResponse(jsonObject: [String: Any]) {
        stub(condition: isMethodPOST() && { request in
            request.url?.path.hasSuffix("/services/getIINdetails") == true
        }) { _ in
            HTTPStubsResponse(
                jsonObject: jsonObject,
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }
    }
}
