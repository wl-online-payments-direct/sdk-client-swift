/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Alamofire
import XCTest

@testable import OnlinePaymentsKit

class ApiClientTestCase: XCTestCase {

    var apiClient: ApiClient!
    var mockUtil: MetadataUtil!
    var sessionData: SessionData!

    override func setUp() {
        super.setUp()

        mockUtil = MetadataUtil()

        sessionData = SessionData(
            clientSessionId: "test-session-123",
            customerId: "customer-456",
            clientApiUrl: "https://api.test.com",
            assetUrl: "https://assets.test.com"
        )

        let urlConfiguration = URLSessionConfiguration.ephemeral
        urlConfiguration.protocolClasses = [MockURLProtocol.self]
        let mockSession = Session(configuration: urlConfiguration)

        apiClient = ApiClient(
            sessionData: sessionData,
            loggingEnabled: false,
            util: mockUtil,
            session: mockSession
        )
    }

    override func tearDown() {
        apiClient = nil
        mockUtil = nil
        sessionData = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testInitializationWithAllParameters() {
        let testSessionData = SessionData(
            clientSessionId: "session",
            customerId: "customer",
            clientApiUrl: "https://api.com",
            assetUrl: "https://assets.com"
        )

        let client = ApiClient(
            sessionData: testSessionData,
            loggingEnabled: true,
            util: mockUtil
        )

        XCTAssertNotNil(client)
    }

    func testInitializationWithMinimalParameters() {
        let testSessionData = SessionData(
            clientSessionId: "session",
            customerId: "customer",
            clientApiUrl: "https://api.com",
            assetUrl: "https://assets.com"
        )

        let client = ApiClient(
            sessionData: testSessionData,
            loggingEnabled: false
        )

        XCTAssertNotNil(client)
    }

    func testHeadersContainAuthorizationAndClientMetaInfo() {
        let headers = apiClient.headers

        XCTAssertTrue(headers.contains { $0.name == "Authorization" })
        XCTAssertTrue(headers.contains { $0.name == "X-GCS-ClientMetaInfo" })

        let authHeader = headers.first { $0.name == "Authorization" }
        XCTAssertEqual(authHeader?.value, "GCS v1Client:test-session-123")
    }

    func testGetRequestSuccess() {
        let expectation = self.expectation(description: "GET request succeeds")

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "GET")

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!

            let json = """
                {
                    "id": "123",
                    "name": "Test Product"
                }
                """.data(using: .utf8)!

            return (response, json)
        }

        struct TestResponse: Codable {
            let id: String
            let name: String
        }

        apiClient.get(
            path: "/products/123",
            parameters: nil,
            additionalAcceptableStatusCodes: nil,
            success: { (response: TestResponse?, statusCode) in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.id, "123")
                XCTAssertEqual(response?.name, "Test Product")
                XCTAssertEqual(statusCode, 200)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error.message)")
            }
        )

        waitForExpectations(timeout: 2.0)
    }

    func testGetRequestWithParameters() {
        let expectation = self.expectation(description: "GET with parameters")

        MockURLProtocol.requestHandler = { request in
            let urlString = request.url?.absoluteString ?? ""
            XCTAssertTrue(urlString.contains("countryCode=US"))
            XCTAssertTrue(urlString.contains("currencyCode=USD"))
            XCTAssertTrue(urlString.contains("amount=1000"))

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            let json = """
                {
                    "products": []
                }
                """.data(using: .utf8)!

            return (response, json)
        }

        struct TestResponse: Codable {
            let products: [String]
        }

        apiClient.get(
            path: "/products",
            parameters: [
                "countryCode": "US",
                "currencyCode": "USD",
                "amount": "1000",
            ],
            additionalAcceptableStatusCodes: nil,
            success: { (response: TestResponse?, statusCode) in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.products.count, 0)
                XCTAssertEqual(statusCode, 200)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error.message)")
            }
        )

        waitForExpectations(timeout: 2.0)
    }

    func testGetRequestWithAdditionalStatusCodes() {
        let expectation = self.expectation(description: "GET with additional status codes")

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!

            let json = """
                {
                    "notFound": true
                }
                """.data(using: .utf8)!

            return (response, json)
        }

        struct TestResponse: Codable {
            let notFound: Bool
        }

        let additionalCodes = IndexSet(integer: 404)

        apiClient.get(
            path: "/test",
            parameters: nil,
            additionalAcceptableStatusCodes: additionalCodes,
            success: { (response: TestResponse?, statusCode) in
                XCTAssertNotNil(response)
                XCTAssertTrue(response?.notFound ?? false)
                XCTAssertEqual(statusCode, 404)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail with 404 when it's acceptable: \(error.message)")
            }
        )

        waitForExpectations(timeout: 2.0)
    }

    func testPostRequestSuccess() {
        let expectation = self.expectation(description: "POST request succeeds")

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 201,
                httpVersion: nil,
                headerFields: nil
            )!

            let json = """
                {
                    "success": true,
                    "paymentId": "123"
                }
                """.data(using: .utf8)!

            return (response, json)
        }

        struct TestResponse: Codable {
            let success: Bool
            let paymentId: String
        }

        apiClient.post(
            path: "/payments",
            parameters: ["cardNumber": "4111111111111111"],
            additionalAcceptableStatusCodes: nil,
            success: { (response: TestResponse?, statusCode) in
                XCTAssertNotNil(response)
                XCTAssertTrue(response?.success ?? false)
                XCTAssertEqual(response?.paymentId, "123")
                XCTAssertEqual(statusCode, 201)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error.message)")
            }
        )

        waitForExpectations(timeout: 2.0)
    }

    func testPostRequestWithNilParameters() {
        let expectation = self.expectation(description: "POST with nil parameters")

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            let json = """
                {
                    "result": "ok"
                }
                """.data(using: .utf8)!

            return (response, json)
        }

        struct TestResponse: Codable {
            let result: String
        }

        apiClient.post(
            path: "/test",
            parameters: nil,
            additionalAcceptableStatusCodes: nil,
            success: { (response: TestResponse?, statusCode) in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.result, "ok")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Should not fail: \(error.message)")
            }
        )

        waitForExpectations(timeout: 2.0)
    }

    func testGetRequestNetworkFailure() {
        let expectation = self.expectation(description: "Network failure is handled")

        MockURLProtocol.requestHandler = { request in
            throw NSError(
                domain: NSURLErrorDomain,
                code: NSURLErrorNotConnectedToInternet,
                userInfo: [
                    NSLocalizedDescriptionKey: "The Internet connection appears to be offline."
                ]
            )
        }

        struct TestResponse: Codable {
            let data: String
        }

        apiClient.get(
            path: "/test",
            parameters: nil,
            additionalAcceptableStatusCodes: nil,
            success: { (response: TestResponse?, statusCode) in
                XCTFail("Should not succeed")
            },
            failure: { error in
                XCTAssertNotNil(error)

                // Check if it's a CommunicationError (network error without status code)
                if let commError = error as? CommunicationError {
                    XCTAssertTrue(commError.message.contains("Communication error"))
                    XCTAssertEqual(commError.code, .clientError)
                } else {
                    XCTFail("Error should be CommunicationError type")
                }

                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 2.0)
    }

    func testPostRequestApiFailure() {
        let expectation = self.expectation(description: "POST API failure")

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 400,
                httpVersion: nil,
                headerFields: nil
            )!

            let json = """
                {
                    "errorId": "VALIDATION_ERROR",
                    "errors": []
                }
                """.data(using: .utf8)!

            return (response, json)
        }

        struct TestResponse: Codable {
            let data: String
        }

        apiClient.post(
            path: "/submit",
            parameters: ["invalid": "data"],
            additionalAcceptableStatusCodes: nil,
            success: { (response: TestResponse?, statusCode) in
                XCTFail("Should not succeed")
            },
            failure: { error in
                XCTAssertNotNil(error)

                if let responseError = error as? ResponseError {
                    XCTAssertEqual(responseError.httpStatusCode, 400)
                    XCTAssertEqual(responseError.code, .clientError)
                    XCTAssertNotNil(responseError.message)
                    XCTAssertFalse(responseError.message.isEmpty)

                    XCTAssertNotNil(responseError.metadata)
                } else {
                    XCTFail("Error should be ResponseError type")
                }

                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 2.0)
    }
}

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("MockURLProtocol request handler is not set")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
