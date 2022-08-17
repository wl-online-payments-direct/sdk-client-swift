//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidators)
public class Validators: NSObject {
    @objc var variableRequiredness = false

    @objc public var validators = [Validator]()
}
