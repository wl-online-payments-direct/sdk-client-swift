//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//
import Foundation

@available(*, deprecated, message: "In a future release, this class will be removed. Use AmountOfMoney instead.")
@objc(OPPaymentAmountOfMoney)
public class PaymentAmountOfMoney: AmountOfMoney {}

internal extension AmountOfMoney {
  func cloneToDeprecatedObject() -> PaymentAmountOfMoney {
      PaymentAmountOfMoney(
          totalAmount: self.totalAmount,
          currencyCode: self.currencyCodeString
      )
  }
 }
