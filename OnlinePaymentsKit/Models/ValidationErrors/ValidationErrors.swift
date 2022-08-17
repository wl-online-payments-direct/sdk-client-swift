//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidationError) public class ValidationError: NSObject { @objc public override init() {} }

@objc(OPValidationErrorAllowed) public class ValidationErrorAllowed: ValidationError {}
@objc(OPValidationErrorEmailAddress) public class ValidationErrorEmailAddress: ValidationError {}
@objc(OPValidationErrorExpirationDate) public class ValidationErrorExpirationDate: ValidationError {}
@objc(OPValidationErrorFixedList) public class ValidationErrorFixedList: ValidationError {}
@objc(OPValidationErrorInteger) public class ValidationErrorInteger: ValidationError {}
@objc(OPValidationErrorIsRequired) public class ValidationErrorIsRequired: ValidationError {}
@objc(OPValidationErrorLuhn) public class ValidationErrorLuhn: ValidationError {}
@objc(OPValidationErrorNumericString) public class ValidationErrorNumericString: ValidationError {}
@objc(OPValidationErrorRegularExpression) public class ValidationErrorRegularExpression: ValidationError {}
@objc(OPValidationErrorTermsAndConditions) public class ValidationErrorTermsAndConditions: ValidationError {}
@objc(OPValidationErrorIBAN) public class ValidationErrorIBAN: ValidationError {}

@objc(OPValidationErrorLength)
public class ValidationErrorLength: ValidationError {
    @objc public var minLength = 0
    @objc public var maxLength = 0
}

@objc(OPValidationErrorRange)
public class ValidationErrorRange: ValidationError {
    @objc public var minValue = 0
    @objc public var maxValue = 0
}
