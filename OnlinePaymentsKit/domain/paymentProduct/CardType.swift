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

@objc(OPCardType) public enum CardType: Int {
    @objc(OPCredit) case credit
    @objc(OPDebit) case debit
    @objc(OPPrepaid) case prepaid
}

internal class CardTypeEnumHandler: NSObject {
    static func getCardType(type: String) -> CardType {
        switch type {
        case "Credit":
            return .credit
        case "Debit":
            return .debit
        case "Prepaid":
            return .prepaid
        default:
            return .credit
        }
    }

    static func getCardTypeString(type: CardType) -> String {
        switch type {
        case .credit:
            return "Credit"
        case .debit:
            return "Debit"
        case .prepaid:
            return "Prepaid"
        }
    }
}
