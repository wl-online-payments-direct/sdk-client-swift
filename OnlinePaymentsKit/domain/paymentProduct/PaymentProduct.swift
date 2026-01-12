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

@objc(OPPaymentProduct) public final class PaymentProduct: BasicPaymentProduct {

    @objc private var _fields: [PaymentProductField] = []

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
        accountsOnFile: [AccountOnFile],
        fields: [PaymentProductField]
    ) {
        self._fields = fields

        super.init(
            id: id,
            label: label,
            logo: logo,
            displayOrder: displayOrder,
            allowsTokenization: allowsTokenization,
            allowsRecurring: allowsRecurring,
            paymentMethod: paymentMethod,
            paymentProductGroup: paymentProductGroup,
            paymentProduct302SpecificData: paymentProduct302SpecificData,
            paymentProduct320SpecificData: paymentProduct320SpecificData,
            usesRedirectionTo3rdParty: usesRedirectionTo3rdParty,
            accountsOnFile: accountsOnFile
        )
    }

    @objc public var fields: [PaymentProductField] {
        _fields
    }

    @objc public var requiredFields: [PaymentProductField] {
        _fields.filter(\.isRequired)
    }

    @objc public func field(id: String) -> PaymentProductField? {
        _fields.first {
            $0.id == id
        }
    }
}
