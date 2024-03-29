//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 02/08/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import XCTest
import OHHTTPStubs
import OHHTTPStubsSwift

@testable import OnlinePaymentsKit

class SurchargeCalculationResponseTestCase: XCTestCase {

    let host = "example.com"

    var session = Session(clientSessionId: "client-session-id",
                          customerId: "customer-id",
                          baseURL: "https://example.com",
                          assetBaseURL: "https://example.com",
                          appIdentifier: "")
    let amountOfMoney = AmountOfMoney(totalAmount: 1000, currencyCode: "EUR")

    private func setupStubSurchargeResponse() {
        stub(
            condition: isHost("\(host)") &&
            isPath("/client/v1/customer-id/services/surchargecalculation") &&
            isMethodPOST()
        ) { _ in
            let response = [
                "surcharges": [
                    [
                        "paymentProductId": 1,
                        "result": "OK",
                        "netAmount": [
                            "amount": 1000,
                            "currencyCode": "EUR"
                        ],
                        "surchargeAmount": [
                            "amount": 366,
                            "currencyCode": "EUR"
                        ],
                        "totalAmount": [
                            "amount": 1366,
                            "currencyCode": "EUR"
                        ],
                        "surchargeRate": [
                            "surchargeProductTypeId": "PAYMENT_PRODUCT_TYPE_ID",
                            "surchargeProductTypeVersion": "1a2b3c-4d5e-6f7g8h-9i0j",
                            "adValoremRate": 3.3,
                            "specificRate": 333
                        ]
                    ]
                ]
            ] as [String: Any]

            return
                HTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
    }

    private func setupStubNoSurchargeResponse() {
        stub(
            condition: isHost("\(host)") &&
            isPath("/client/v1/customer-id/services/surchargecalculation") &&
            isMethodPOST()
        ) { _ in
            let response = [
                "surcharges": [
                    [
                        "paymentProductId": 2,
                        "result": "NO_SURCHARGE",
                        "netAmount": [
                            "amount": 1000,
                            "currencyCode": "EUR"
                        ],
                        "surchargeAmount": [
                            "amount": 0,
                            "currencyCode": "EUR"
                        ],
                        "totalAmount": [
                            "amount": 1000,
                            "currencyCode": "EUR"
                        ]
                    ]
                ]
            ] as [String: Any]

            return
                HTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
    }

    func testSurchargeCalculationWithCardWithPaymentProductId() {
        self.setupStubSurchargeResponse()

        let expectation = self.expectation(description: "Response provided")

        session.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            partialCreditCardNumber: "123456",
            paymentProductId: 1,
            success: { response in
                self.assertSurchargeResponseValues(response: response)

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure while getting Surcharge calculation: \(error.localizedDescription)")
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testSurchargeCalculationWithCardWithoutPaymentProductId() {
        self.setupStubSurchargeResponse()

        let expectation = self.expectation(description: "Response provided")

        session.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            partialCreditCardNumber: "123456",
            success: { response in
                self.assertSurchargeResponseValues(response: response)

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure while getting Surcharge calculation: \(error.localizedDescription)")
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testSurchargeCalculationWithToken() {
        self.setupStubSurchargeResponse()

        let expectation = self.expectation(description: "Response provided")

        session.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            token: "0j9i8h-7g6f5e-4d3c-2b1a",
            success: { response in
                self.assertSurchargeResponseValues(response: response)

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure while getting Surcharge calculation: \(error.localizedDescription)")
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testNoSurchargeCalculationWithCardWithPaymentProductId() {
        self.setupStubNoSurchargeResponse()

        let expectation = self.expectation(description: "Response provided")

        session.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            partialCreditCardNumber: "987654",
            paymentProductId: 2,
            success: { response in
                self.assertNoSurchargeResponseValues(response: response)

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure while getting Surcharge calculation: \(error.localizedDescription)")
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testNoSurchargeCalculationWithCardWithoutPaymentProductId() {
        self.setupStubNoSurchargeResponse()

        let expectation = self.expectation(description: "Response provided")

        session.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            partialCreditCardNumber: "987654",
            success: { response in
                self.assertNoSurchargeResponseValues(response: response)

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure while getting Surcharge calculation: \(error.localizedDescription)")
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testNoSurchargeCalculationWithToken() {
        self.setupStubNoSurchargeResponse()

        let expectation = self.expectation(description: "Response provided")

        session.surchargeCalculation(
            amountOfMoney: amountOfMoney,
            token: "j0i9h8-g7f6e5-d43c-b2a1",
            success: { response in
                self.assertNoSurchargeResponseValues(response: response)

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure while getting Surcharge calculation: \(error.localizedDescription)")
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    private func assertSurchargeResponseValues(response: SurchargeCalculationResponse) {
        XCTAssertEqual(response.surcharges.count, 1)

        let surcharge = response.surcharges.first

        XCTAssertEqual(surcharge?.paymentProductId, 1)
        XCTAssertEqual(surcharge?.result, SurchargeResult.ok)
        XCTAssertEqual(surcharge?.netAmount.totalAmount, 1000)
        XCTAssertEqual(surcharge?.netAmount.currencyCode, "EUR")
        XCTAssertEqual(surcharge?.surchargeAmount.totalAmount, 366)
        XCTAssertEqual(surcharge?.surchargeAmount.currencyCode, "EUR")
        XCTAssertEqual(surcharge?.totalAmount.totalAmount, 1366)
        XCTAssertEqual(surcharge?.totalAmount.currencyCode, "EUR")
        XCTAssertEqual(surcharge?.surchargeRate?.surchargeProductTypeId, "PAYMENT_PRODUCT_TYPE_ID")
        XCTAssertEqual(surcharge?.surchargeRate?.surchargeProductTypeVersion, "1a2b3c-4d5e-6f7g8h-9i0j")
        XCTAssertEqual(surcharge?.surchargeRate?.adValoremRate, 3.3)
        XCTAssertEqual(surcharge?.surchargeRate?.specificRate, 333)
    }

    private func assertNoSurchargeResponseValues(response: SurchargeCalculationResponse) {
        XCTAssertEqual(response.surcharges.count, 1)

        let surcharge = response.surcharges.first

        XCTAssertEqual(surcharge?.paymentProductId, 2)
        XCTAssertEqual(surcharge?.result, SurchargeResult.noSurcharge)
        XCTAssertEqual(surcharge?.netAmount.totalAmount, 1000)
        XCTAssertEqual(surcharge?.netAmount.currencyCode, "EUR")
        XCTAssertEqual(surcharge?.surchargeAmount.totalAmount, 0)
        XCTAssertEqual(surcharge?.surchargeAmount.currencyCode, "EUR")
        XCTAssertEqual(surcharge?.totalAmount.totalAmount, 1000)
        XCTAssertEqual(surcharge?.totalAmount.currencyCode, "EUR")
        XCTAssertNil(surcharge?.surchargeRate)
    }
}
