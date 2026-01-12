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

class SurchargeCalculationResponseTestCase: XCTestCase {

    var clientService: ClientService!
    var mockApiClient: ApiClientMock!
    var mockCacheManager: CacheManagerMock!
    var sessionData: SessionData!
    let amountOfMoney = AmountOfMoney(amount: 1000, currencyCode: "EUR")

    override func setUp() {
        super.setUp()

        mockApiClient = ApiClientMock()
        mockCacheManager = CacheManagerMock()

        sessionData = SessionData(
            clientSessionId: "client-session-id",
            customerId: "customer-id",
            clientApiUrl: "https://example.com",
            assetUrl: "https://example.com"
        )

        clientService = ClientService(
            apiClient: mockApiClient,
            cacheManager: mockCacheManager,
            sessionData: sessionData
        )
    }

    override func tearDown() {
        clientService = nil
        mockApiClient = nil
        mockCacheManager = nil
        sessionData = nil
        super.tearDown()
    }

    private func setupStubSurchargeResponse() {
        let response = try! FixtureLoader.loadJSON("surchargeCalculationResponse", as: SurchargeCalculationResponse.self)
        mockApiClient.mockPostResponses["/services/surchargecalculation"] = response
    }

    private func setupStubNoSurchargeResponse() {
        let jsonString = """
        {
            "surcharges": [
                {
                    "paymentProductId": 2,
                    "result": "NO_SURCHARGE",
                    "netAmount": {
                        "amount": 1000,
                        "currencyCode": "EUR"
                    },
                    "surchargeAmount": {
                        "amount": 0,
                        "currencyCode": "EUR"
                    },
                    "totalAmount": {
                        "amount": 1000,
                        "currencyCode": "EUR"
                    }
                }
            ]
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        let response = try! JSONDecoder().decode(SurchargeCalculationResponse.self, from: jsonData)
        mockApiClient.mockPostResponses["/services/surchargecalculation"] = response
    }

    func testSurchargeCalculation_WithCardWithPaymentProductId() {
        self.setupStubSurchargeResponse()

        let expectation = self.expectation(description: "Response provided")

        clientService.surchargeCalculation(
            withAmountOfMoney: amountOfMoney,
            forCardSource: CardSource(card: Card(cardNumber: "400000", paymentProductId: 1)),
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

    func testSurchargeCalculation_WithCardWithoutPaymentProductId() {
        self.setupStubSurchargeResponse()

        let expectation = self.expectation(description: "Response provided")

        clientService.surchargeCalculation(
            withAmountOfMoney: amountOfMoney,
            forCardSource: CardSource(card: Card(cardNumber: "400000", paymentProductId: nil)),
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

    func testSurchargeCalculation_WithToken() {
        self.setupStubSurchargeResponse()

        let expectation = self.expectation(description: "Response provided")

        clientService.surchargeCalculation(
            withAmountOfMoney: amountOfMoney,
            forCardSource: CardSource(token: "0j9i8h-7g6f5e-4d3c-2b1a"),
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

    func testNoSurchargeCalculation_WithCardWithPaymentProductId() {
        self.setupStubNoSurchargeResponse()

        let expectation = self.expectation(description: "Response provided")

        clientService.surchargeCalculation(
            withAmountOfMoney: amountOfMoney,
            forCardSource: CardSource(card: Card(cardNumber: "987654", paymentProductId: 2)),
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

    func testNoSurchargeCalculation_WithCardWithoutPaymentProductId() {
        self.setupStubNoSurchargeResponse()

        let expectation = self.expectation(description: "Response provided")

        clientService.surchargeCalculation(
            withAmountOfMoney: amountOfMoney,
            forCardSource: CardSource(card: Card(cardNumber: "987654", paymentProductId: nil)),
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

    func testNoSurchargeCalculation_WithToken() {
        self.setupStubNoSurchargeResponse()

        let expectation = self.expectation(description: "Response provided")

        clientService.surchargeCalculation(
            withAmountOfMoney: amountOfMoney,
            forCardSource: CardSource(token: "0j9i8h-7g6f5e-4d3c-2b1a"),
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
        XCTAssertEqual(surcharge?.netAmount.amount, 1000)
        XCTAssertEqual(surcharge?.netAmount.currencyCode, "EUR")
        XCTAssertEqual(surcharge?.surchargeAmount.amount, 366)
        XCTAssertEqual(surcharge?.surchargeAmount.currencyCode, "EUR")
        XCTAssertEqual(surcharge?.totalAmount.amount, 1366)
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
        XCTAssertEqual(surcharge?.netAmount.amount, 1000)
        XCTAssertEqual(surcharge?.netAmount.currencyCode, "EUR")
        XCTAssertEqual(surcharge?.surchargeAmount.amount, 0)
        XCTAssertEqual(surcharge?.surchargeAmount.currencyCode, "EUR")
        XCTAssertEqual(surcharge?.totalAmount.amount, 1000)
        XCTAssertEqual(surcharge?.totalAmount.currencyCode, "EUR")
        XCTAssertNil(surcharge?.surchargeRate)
    }
}
