//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import IngenicoDirectKit

class C2SCommunicatorConfigurationTestCase: XCTestCase {
    var configuration: C2SCommunicatorConfiguration!
    let util = StubUtil()
    
    override func setUp() {
        super.setUp()
        
        configuration = C2SCommunicatorConfiguration(clientSessionId: "", customerId: "", region: .EU, environment: .sandbox, appIdentifier: "", util: util)
    }
    
    func testBaseURL() {
        XCTAssertEqual(configuration.baseURL, "c2sbaseurlbyregion", "Unexpected base URL")
    }
    
    func testAssetsBaseURL() {
        XCTAssertEqual(configuration.assetsBaseURL, "assetsbaseurlbyregion", "Unexpected assets base URL")
    }
    
    func testBase64EncodedClientMetaInfo() {
        print(configuration.base64EncodedClientMetaInfo ?? "leeg")
        XCTAssertEqual(configuration.base64EncodedClientMetaInfo, "base64encodedclientmetainfo", "Unexpected encoded client meta info")
    }
}
