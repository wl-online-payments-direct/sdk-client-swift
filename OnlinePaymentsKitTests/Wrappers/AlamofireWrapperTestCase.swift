//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
import OHHTTPStubs
import OHHTTPStubsSwift

@testable import OnlinePaymentsKit

class AlamofireWrapperTestCase: XCTestCase {
  let baseURL = "https://example.com/client/v1"

  let host = "example.com"
  let merchantId = 1234

  override func setUp() {
    super.setUp()

    // Stub GET request
    stub(condition: isHost("\(host)") && isPath("/client/v1/\(merchantId)/crypto/publickey") && isMethodGET()) { _ in
      let response = [
        "errors": [[
          "code": 9002,
          "message": "MISSING_OR_INVALID_AUTHORIZATION"
        ]]
      ]
      return HTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type": "application/json"])
    }

    // Stub POST request
    stub(condition: isHost("\(host)") && isPath("/client/v1/\(merchantId)/sessions") && isMethodPOST()) { _ in
      let response = [
        "errors": [[
          "code": 9002,
          "message": "MISSING_OR_INVALID_AUTHORIZATION"
          ]]
        ]
      return HTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type": "application/json"])
    }

    stub(condition: isHost("\(host)") && isPath("/client/v1/noerror") && isMethodGET()) { _ in
      return HTTPStubsResponse(jsonObject: [], statusCode: 401, headers: ["Content-Type": "application/json"])
    }

    stub(condition: isHost("\(host)") && isPath("/client/v1/error") && isMethodGET()) { _ in
      return HTTPStubsResponse(jsonObject: [], statusCode: 500, headers: ["Content-Type": "application/json"])
    }
  }

  func testPost() {
    let sessionsURL = "\(baseURL)/\(merchantId)/sessions"
    let expectation = self.expectation(description: "Response provided")

    AlamofireWrapper.shared.postResponse(
        forURL: sessionsURL,
        headers: nil,
        withParameters: nil,
        additionalAcceptableStatusCodes: nil,
        success: { responseObject in
          self.assertErrorResponse(responseObject, expectation: expectation)
        },
        failure: { error in
          XCTFail("Unexpected failure while testing POST request: \(error.localizedDescription)")
        }
    )

    waitForExpectations(timeout: 3) { error in
      if let error = error {
        print("Timeout error: \(error.localizedDescription)")
      }
    }
  }

  func testGet() {
    let publicKeyURL = "\(baseURL)/\(merchantId)/crypto/publickey"
    let expectation = self.expectation(description: "Response provided")

    AlamofireWrapper.shared.getResponse(
        forURL: publicKeyURL,
        headers: nil,
        additionalAcceptableStatusCodes: nil,
        success: { responseObject in
          self.assertErrorResponse(responseObject, expectation: expectation)
        },
        failure: { error in
          XCTFail("Unexpected failure while testing GET request: \(error.localizedDescription)")
        }
    )

    waitForExpectations(timeout: 3) { error in
      if let error = error {
        print("Timeout error: \(error.localizedDescription)")
      }
    }
  }

  func testAdditionalStatusCodeAcceptance() {
    let publicKeyURL = "\(baseURL)/noerror"
    let expectation = self.expectation(description: "Response provided")
    let additionalAcceptableStatusCodes: IndexSet = [401]

    AlamofireWrapper.shared.getResponse(
        forURL: publicKeyURL,
        headers: nil,
        additionalAcceptableStatusCodes: additionalAcceptableStatusCodes,
        success: { _ in
          expectation.fulfill()
        },
        failure: { error in
          XCTFail("Additional status code did not accept: \(error.localizedDescription)")
        }
    )

    waitForExpectations(timeout: 3) { error in
      if let error = error {
        print("Timeout error: \(error.localizedDescription)")
      }
    }
  }

  func testRequestFailure() {
    let publicKeyURL = "\(baseURL)/error"
    let expectation = self.expectation(description: "Response provided")

    AlamofireWrapper.shared.getResponse(
        forURL: publicKeyURL,
        headers: nil,
        additionalAcceptableStatusCodes: nil,
        success: { _ in
          XCTFail("Failure should have been called")
        },
        failure: { _ in
          expectation.fulfill()
        }
    )

    waitForExpectations(timeout: 3) { error in
      if let error = error {
        print("Timeout error: \(error.localizedDescription)")
      }
    }
  }

  fileprivate func assertErrorResponse(_ errorResponse: [String: Any]?, expectation: XCTestExpectation) {
    if let errorResponse = errorResponse,
    let errors = errorResponse["errors"] as? [[String: Any]],
       let firstError = errors.first {
      XCTAssertEqual(firstError["code"] as? Int, 9002)
      XCTAssertEqual(firstError["message"] as? String, "MISSING_OR_INVALID_AUTHORIZATION")
      expectation.fulfill()
    }
  }
}
