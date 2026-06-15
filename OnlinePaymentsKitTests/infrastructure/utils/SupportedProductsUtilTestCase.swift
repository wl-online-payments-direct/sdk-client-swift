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

class SupportedProductsUtilTestCase: XCTestCase {

    func testIsSupportedInSdkReturnsTrueForSupportedProduct() {
        XCTAssertTrue(SupportedProductsUtil.isSupportedInSdk(1))
    }

    func testIsSupportedInSdkReturnsFalseForKnownUnsupportedProducts() {
        XCTAssertFalse(SupportedProductsUtil.isSupportedInSdk(117))
        XCTAssertFalse(SupportedProductsUtil.isSupportedInSdk(5700))
        XCTAssertFalse(SupportedProductsUtil.isSupportedInSdk(5772))
        XCTAssertFalse(SupportedProductsUtil.isSupportedInSdk(5784))
    }

    func testGet404ErrorReturnsExpectedErrorResponse() {
        let error = SupportedProductsUtil.get404Error()

        XCTAssertEqual(error.errors.count, 1)

        let item = error.errors[0]
        XCTAssertEqual(item.httpStatusCode, 404)
        XCTAssertEqual(item.errorCode, "1007")
        XCTAssertEqual(item.propertyName, "productId")
    }
}
