//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPValidationError) public class ValidationError: NSObject, Codable {
    @objc public var errorMessage: String = ""
    @objc public var paymentProductFieldId: String?
    @objc public var rule: Validator?

    @objc public override init() {}

    @objc public init(errorMessage: String, paymentProductFieldId: String?, rule: Validator?) {
        self.errorMessage = errorMessage
        self.paymentProductFieldId = paymentProductFieldId
        self.rule = rule
    }
}

@objc(OPValidationErrorAllowed) public class ValidationErrorAllowed: ValidationError {}
@objc(OPValidationErrorEmailAddress) public class ValidationErrorEmailAddress: ValidationError {}
@objc(OPValidationErrorExpirationDate) public class ValidationErrorExpirationDate: ValidationError {}
@objc(OPValidationErrorFixedList) public class ValidationErrorFixedList: ValidationError {}

@objc(OPValidationErrorInteger)
@available(*, deprecated, message: "In a future release, this class will be removed.")
public class ValidationErrorInteger: ValidationError {}

@objc(OPValidationErrorIsRequired) public class ValidationErrorIsRequired: ValidationError {}
@objc(OPValidationErrorLuhn) public class ValidationErrorLuhn: ValidationError {}

@objc(OPValidationErrorNumericString)
@available(*, deprecated, message: "In a future release, this class will be removed.")
public class ValidationErrorNumericString: ValidationError {}

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
@objc(OPValidationErrorPaymentProductMissing) public class ValidationErrorInvalidPaymentProduct: ValidationError {}
