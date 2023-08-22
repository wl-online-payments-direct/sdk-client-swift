//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Alamofire
import Foundation

@available(
    *,
    deprecated,
    message:
        """
        In a future release, this class, its functions and its properties will become internal to the SDK.
        """
)
public class AlamofireWrapper: NSObject {

    static let shared = AlamofireWrapper()

    public var headers: HTTPHeaders? {
        get {
            return URLSessionConfiguration.default.headers
        }
        set {
            URLSessionConfiguration.default.headers = newValue ?? .default
        }
    }

    // swiftlint:disable function_parameter_count
    public func getResponse(forURL URL: String,
                            withParameters parameters: Parameters? = nil,
                            headers: HTTPHeaders?,
                            additionalAcceptableStatusCodes: IndexSet?,
                            success: @escaping (_ responseObject: [String: Any]?) -> Void,
                            failure: @escaping (_ error: Error) -> Void) {

        let acceptableStatusCodes = NSMutableIndexSet(indexesIn: NSRange(location: 200, length: 100))
        if let additionalAcceptableStatusCodes = additionalAcceptableStatusCodes {
            acceptableStatusCodes.add(additionalAcceptableStatusCodes)
        }

        AF
            .request(URL, method: .get, parameters: parameters, headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseJSON { response in
                if let error = response.error {
                    Macros.DLog(
                        message: "Error while retrieving response for URL \(URL): \(error.localizedDescription)"
                    )
                    failure(error)
                } else {
                    var responseObject = response.value as? [String: Any]
                    responseObject?["statusCode"] = response.response?.statusCode

                    success(responseObject)
                }
        }
    }

    public func postResponse(forURL URL: String,
                             headers: HTTPHeaders?,
                             withParameters parameters: Parameters?,
                             additionalAcceptableStatusCodes: IndexSet?,
                             success: @escaping (_ responseObject: [String: Any]?) -> Void,
                             failure: @escaping (_ error: Error) -> Void) {

        let acceptableStatusCodes = NSMutableIndexSet(indexesIn: NSRange(location: 200, length: 100))
        if let additionalAcceptableStatusCodes = additionalAcceptableStatusCodes {
            acceptableStatusCodes.add(additionalAcceptableStatusCodes)
        }

        AF
            .request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseJSON { response in
                if let error = response.error {
                    Macros.DLog(
                        message: "Error while retrieving response for URL \(URL): \(error.localizedDescription)"
                    )
                    failure(error)
                } else {
                    var responseObject = response.value as? [String: Any]
                    responseObject?["statusCode"] = response.response?.statusCode

                    success(responseObject)
                }
        }
    }
    // swiftlint:enable function_parameter_count
}
