//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

public class AccountOnFileAttributes {

    public var attributes = [AccountOnFileAttribute]()

    public func value(forField paymentProductFieldId: String) -> String {
        for attribute in attributes {
            if attribute.key == paymentProductFieldId, let val = attribute.value {
                return val
            }
        }

        return ""
    }

    public func hasValue(forField paymentProductFieldId: String) -> Bool {
        for attribute in attributes
            where attribute.key == paymentProductFieldId {
                return true
        }

        return false
    }

    public func isReadOnly(field paymentProductFieldId: String?) -> Bool {
        guard let field = paymentProductFieldId else {
            return false
        }
        for attribute in attributes
            where attribute.key.isEqual(field) {
                return attribute.status == .readOnly
        }
        return false
    }

}
