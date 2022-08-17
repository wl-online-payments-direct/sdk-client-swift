//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

@objc(OPIINDetailsResponse)
public class IINDetailsResponse: NSObject, ResponseObjectSerializable {

    @objc public var paymentProductId: String?
    @objc public var status: IINStatus = .supported
    @objc public var coBrands = [IINDetail]()
    public var countryCode: CountryCode?
    @objc public var countryCodeString: String?
    @objc public var allowedInContext = false

    private override init() {}

    @objc required public init(json: [String: Any]) {
        if let input = json["isAllowedInContext"] as? Bool {
            allowedInContext = input
        }

        if let input = json["paymentProductId"] as? Int {
            paymentProductId = "\(input)"
            if !allowedInContext {
                status = .existingButNotAllowed
            }
        } else {
            status = .unknown
        }
        
        if let input = json["countryCode"] as? String {
            countryCode = CountryCode.init(rawValue: input)
            countryCodeString = input
        }

        if let input = json["coBrands"] as? [[String: Any]] {
            coBrands = []
            for detailInput in input {
                if let detail = IINDetail(json: detailInput) {
                    coBrands.append(detail)
                }
            }
        }
    }

    @objc convenience public init(status: IINStatus) {
        self.init()
        self.status = status
    }

    @objc convenience public init(paymentProductId: String, status: IINStatus, coBrands: [IINDetail], countryCode: String, allowedInContext: Bool) {
        self.init()
        self.paymentProductId = paymentProductId
        self.status = status
        self.coBrands = coBrands
        self.countryCode = CountryCode.init(rawValue: countryCode)
        self.countryCodeString = countryCode
        self.allowedInContext = allowedInContext
    }

}
