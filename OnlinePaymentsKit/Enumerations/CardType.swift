//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 28/09/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPCardType)
public enum CardType: Int {
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
