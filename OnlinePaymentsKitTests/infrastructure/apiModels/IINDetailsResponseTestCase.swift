/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest

@testable import OnlinePaymentsKit

class IINDetailsResponseTestCase: XCTestCase {

    let host = "example.com"

    var clientService: ClientService!
    var apiClient: ApiClientMock!
    var cacheManager: CacheManager!
    var sessionData: SessionData!

    let context = PaymentContext(
        amountOfMoney: AmountOfMoney(amount: 3, currencyCode: "EUR"),
        isRecurring: true,
        countryCode: "NL"
    )

    override func setUp() {
        super.setUp()

        sessionData = SessionData(
            clientSessionId: "client-session-id",
            customerId: "customer-id",
            clientApiUrl: "https://example.com",
            assetUrl: "https://example.com"
        )

        cacheManager = CacheManager()
        apiClient = ApiClientMock()
        clientService = ClientService(
            apiClient: apiClient,
            cacheManager: cacheManager,
            sessionData: sessionData
        )

        stub(condition: isHost(host) && isMethodPOST()) { request in
            let url = request.url?.absoluteString ?? "nil"
            XCTFail("Service called unexpected endpoint: \(url)")
            return HTTPStubsResponse(error: NSError(domain: "Tests", code: 1, userInfo: nil))
        }

        let response = IINDetailsResponse(status: .supported)
        response.paymentProductId = 3
        response.countryCode = "RU"
        response.cardType = .debit
        let coBrand = IINDetail(paymentProductId: 1, allowedInContext: true)
        response.coBrands = [coBrand]

        apiClient.mockPostResponses["/services/getIINdetails"] = response
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        clientService = nil
        apiClient = nil
        cacheManager = nil
        sessionData = nil
        super.tearDown()
    }

    func testGetIINDetailsNotEnoughDigits() {
        let expectation = self.expectation(description: "Response provided")
        clientService.iinDetails(
            forBin: "22",
            forContext: context,
            success: { (response) in
                XCTAssertTrue(
                    response.status == .notEnoughDigits,
                    "Did not get the correct response status: \(response.status)"
                )
                expectation.fulfill()
            },
            failure: { (error) in
                XCTFail("Unexpected failure while getting IIN Details: \(error.message)")
            }
        )
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testGetIINDetails() {
        let expectation = self.expectation(description: "Response provided")
        clientService.iinDetails(
            forBin: "666666",
            forContext: context,
            success: { (response) in
                XCTAssertTrue(
                    response.paymentProductId == 3,
                    "Payment product ID did not match: \(String(describing: response.paymentProductId))"
                )
                XCTAssertEqual(
                    response.countryCode,
                    "RU",
                    "Country code did not match: \(String(describing: response.countryCode))"
                )

                let details = IINDetail(paymentProductId: response.paymentProductId!, allowedInContext: true)
                XCTAssertTrue(
                    details.paymentProductId == response.paymentProductId,
                    "Payment product ID did not match."
                )
                XCTAssertTrue(details.allowedInContext, "allowedInContext was false.")
                XCTAssertTrue(response.coBrands.count == 1, "Unexpected result. There should be one Co Brand.")
                expectation.fulfill()
                XCTAssert(response.cardType == .debit, "cardType should be Debit")
            },
            failure: { (error) in
                XCTFail("Unexpected failure while getting IIN Details: \(error.message)")
            }
        )
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
}
