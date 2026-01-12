/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation

@objc(OPCreditCardTokenRequest) public class CreditCardTokenRequest: NSObject {
    @objc public var cardNumber: String?
    @objc public var cardholderName: String?
    @objc public var expiryDate: String?
    @objc public var securityCode: String?
    @objc public var paymentProductId: NSNumber?

    @objc public convenience override init() {
        self.init(cardNumber: nil, cardholderName: nil, expiryDate: nil, securityCode: nil, paymentProductId: nil)
    }

    @objc public init(
        cardNumber: String?,
        cardholderName: String?,
        expiryDate: String?,
        securityCode: String?,
        paymentProductId: NSNumber?
    ) {
        self.cardNumber = cardNumber
        self.cardholderName = cardholderName
        self.expiryDate = expiryDate
        self.securityCode = securityCode
        self.paymentProductId = paymentProductId
        super.init()
    }

    @objc public func getValues() -> [String: String] {
        var values: [String: String] = [:]

        if let cardNumber = cardNumber {
            values["cardNumber"] = cardNumber
        }
        if let cardholderName = cardholderName {
            values["cardholderName"] = cardholderName
        }
        if let expiryDate = expiryDate {
            values["expiryDate"] = expiryDate
        }
        if let securityCode = securityCode {
            values["cvv"] = securityCode
        }

        return values
    }
}
