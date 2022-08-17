//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 08/06/2022
// Copyright © 2022 Global Collect Services. All rights reserved.
// 

import UIKit
import Foundation
@testable import OnlinePaymentsKit

class StubSession: OnlinePaymentsKit.Session {
    override func setLogoForDisplayHintsList(for displayHints: [PaymentItemDisplayHints], completion: @escaping() -> Void) {
        var counter = 0;
        for displayHint in displayHints {
            counter += 1
            
            displayHint.logoImage = UIImage()
            displayHint.logoImage?.accessibilityLabel = "logoStubResponse"
            
            if(counter == displayHints.count) {
                completion()
            }
        }
    }
    
    override func setLogoForDisplayHints(for displayHints: PaymentItemDisplayHints, completion: @escaping() -> Void) {
        displayHints.logoImage = UIImage()
        displayHints.logoImage?.accessibilityLabel = "logoStubResponse"
        
        completion()
    }
}
