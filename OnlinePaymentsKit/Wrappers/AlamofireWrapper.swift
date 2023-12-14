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
    @available(
        *,
        deprecated,
        message:
            """
            In a future release, this function will be removed.
            """
    )
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

    internal func getResponse<T: Codable>(forURL URL: String,
                                          headers: HTTPHeaders?,
                                          withParameters parameters: Parameters? = nil,
                                          additionalAcceptableStatusCodes: IndexSet?,
                                          success: @escaping ((responseObject: T?, statusCode: Int?)) -> Void,
                                          failure: @escaping (_ error: Error) -> Void,
                                          apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil) {

        let acceptableStatusCodes = NSMutableIndexSet(indexesIn: NSRange(location: 200, length: 100))
        if let additionalAcceptableStatusCodes = additionalAcceptableStatusCodes {
            acceptableStatusCodes.add(additionalAcceptableStatusCodes)
        }

        AF
            .request(URL, method: .get, parameters: parameters, headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseDecodable(of: T.self) { response in
                if let error = response.error {
                    if error.responseCode != nil {
                        // Error related to unacceptable status code
                        // If response is 403 it has no data, so will not be able to decode the api error
                        let apiError = try? JSONDecoder().decode(ApiError.self, from: response.data ?? Data())

                        let errorResponse = ErrorResponse(message: error.localizedDescription, apiError: apiError)
                        apiFailure?(errorResponse)
                    } else {
                        // Error unrelated to status codes
                        Macros.DLog(
                            message: "Error while retrieving response for URL \(URL): \(error.localizedDescription)"
                        )
                        failure(error)
                    }
                } else {
                    success((response.value, response.response?.statusCode))
                }
            }
    }

    @available(
        *,
        deprecated,
        message:
            """
            In a future release, this function will be removed.
            """
    )
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

    internal func postResponse<T: Codable>(forURL URL: String,
                                           headers: HTTPHeaders?,
                                           withParameters parameters: Parameters?,
                                           additionalAcceptableStatusCodes: IndexSet?,
                                           success: @escaping ((responseObject: T?, statusCode: Int?)) -> Void,
                                           failure: @escaping (_ error: Error) -> Void,
                                           apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil) {

        let acceptableStatusCodes = NSMutableIndexSet(indexesIn: NSRange(location: 200, length: 100))
        if let additionalAcceptableStatusCodes = additionalAcceptableStatusCodes {
            acceptableStatusCodes.add(additionalAcceptableStatusCodes)
        }

        AF
            .request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseDecodable(of: T.self) { response in
                if let error = response.error {
                    if error.responseCode != nil {
                        // Error related to unacceptable status code
                        // If response is 403 it has no data, so will not be able to decode the api error
                        let apiError = try? JSONDecoder().decode(ApiError.self, from: response.data ?? Data())

                        let errorResponse = ErrorResponse(message: error.localizedDescription, apiError: apiError)
                        apiFailure?(errorResponse)
                    } else {
                        // Error unrelated to status codes
                        Macros.DLog(
                            message: "Error while retrieving response for URL \(URL): \(error.localizedDescription)"
                        )
                        failure(error)
                    }
                } else {
                    success((response.value, response.response?.statusCode))
                }
            }
    }
    // swiftlint:enable function_parameter_count
}
