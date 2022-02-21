//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

class StubBundle: Bundle {
    override func path(forResource name: String?, ofType ext: String?) -> String? {
        switch name! {
        case "imageMapping":
            return "imageMappingFile"

        default:
            return nil
        }
    }
}
