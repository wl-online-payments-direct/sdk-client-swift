//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPAccountsOnFile)
public class AccountsOnFile: NSObject {

    @objc public var accountsOnFile = [AccountOnFile]()

    @objc public func accountOnFile(withIdentifier identifier: String) -> AccountOnFile? {
        for accountOnFile in accountsOnFile
            where accountOnFile.identifier.isEqual(identifier) {
                return accountOnFile
        }
        return nil
    }
    
    internal override init() {}
}
