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

@objc(OPAccountOnFile) public final class AccountOnFile: NSObject {

    @objc public let id: String
    @objc public let paymentProductId: Int
    @objc public let label: String?

    @objc public var attributes: [AccountOnFileAttribute] = []
    private let attributeByKey: [String: AccountOnFileAttribute]

    internal init(
        id: String,
        paymentProductId: Int,
        label: String?,
        attributes: [AccountOnFileAttribute]
    ) {
        self.id = id
        self.paymentProductId = paymentProductId
        self.label = label
        self.attributes = attributes
        self.attributeByKey = Dictionary(
            uniqueKeysWithValues: attributes.map {
                ($0.key, $0)
            }
        )

        super.init()
    }

    @objc public func getValue(id: String) -> String? {
        return attributeByKey[id]?.value
    }

    public func getRequiredAttributes() -> [AccountOnFileAttribute] {
        return attributes.filter {
            $0.status == AccountOnFileAttributeStatus.mustWrite
        }
    }

    @objc public func isWritable(id: String) -> Bool {
        return attributeByKey[id]?.status != AccountOnFileAttributeStatus.readOnly
    }
}
