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
import UIKit

@objc(OPBasicPaymentProduct) public class BasicPaymentProduct: NSObject {

    public let id: Int?
    @objc public var idValue: NSNumber? {
        guard let id = id else { return nil }
        return NSNumber(value: id)
    }
    @objc public let label: String?
    @objc public let logo: String?
    @objc public let displayOrder: Int
    @objc public let allowsTokenization: Bool
    @objc public let allowsRecurring: Bool
    @objc public let paymentMethod: String
    @objc public let paymentProductGroup: String?
    @objc public let paymentProduct302SpecificData: PaymentProduct302SpecificData?
    @objc public let paymentProduct320SpecificData: PaymentProduct320SpecificData?
    @objc public let usesRedirectionTo3rdParty: Bool
    @objc private var logoImage: UIImage?

    @objc public let accountsOnFile: [AccountOnFile]

    internal init(
        id: Int?,
        label: String?,
        logo: String?,
        displayOrder: Int,
        allowsTokenization: Bool,
        allowsRecurring: Bool,
        paymentMethod: String,
        paymentProductGroup: String?,
        paymentProduct302SpecificData: PaymentProduct302SpecificData?,
        paymentProduct320SpecificData: PaymentProduct320SpecificData?,
        usesRedirectionTo3rdParty: Bool,
        accountsOnFile: [AccountOnFile]
    ) {
        self.id = id
        self.label = label
        self.logo = logo
        self.displayOrder = displayOrder
        self.allowsTokenization = allowsTokenization
        self.allowsRecurring = allowsRecurring
        self.paymentMethod = paymentMethod
        self.paymentProductGroup = paymentProductGroup
        self.paymentProduct302SpecificData = paymentProduct302SpecificData
        self.paymentProduct320SpecificData = paymentProduct320SpecificData
        self.usesRedirectionTo3rdParty = usesRedirectionTo3rdParty
        self.accountsOnFile = accountsOnFile

        super.init()
    }

    @objc public func accountOnFile(withIdentifier identifier: String) -> AccountOnFile? {
        return accountsOnFile.first {
            $0.id == identifier
        }
    }

    @objc public func getLogoImage() -> UIImage? {
        return logoImage
    }

    @objc internal func updateLogoImage(_ image: UIImage?) {
        self.logoImage = image
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? BasicPaymentProduct else {
            return false
        }
        return self.id == other.id
    }

    public override var hash: Int {
        return id?.hashValue ?? 0
    }
}
