//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

internal import Alamofire
import Foundation

struct SendableIndexSet: Sequence {
    var indexSet: IndexSet

    init(integersIn range: Range<Int>) {
        self.indexSet = IndexSet(integersIn: range)
    }

    init(_ indexSet: IndexSet) {
        self.indexSet = indexSet
    }

    mutating func formUnion(_ other: IndexSet) {
        indexSet.formUnion(other)
    }

    func makeIterator() -> IndexSet.Iterator {
        indexSet.makeIterator()
    }
}


internal class AlamofireWrapper {

    static let shared = AlamofireWrapper()

    private func getAcceptableStatusCodes(additionalStatusCodes: IndexSet?) -> SendableIndexSet {
        var acceptableStatusCodes = SendableIndexSet(integersIn: 200..<300)

        if let extra = additionalStatusCodes {
            acceptableStatusCodes.formUnion(extra)
        }

        return acceptableStatusCodes
    }

    // swiftlint:disable function_parameter_count
    internal func getResponse<T: Codable>(forURL URL: String,
                                          headers: HTTPHeaders?,
                                          withParameters parameters: Parameters? = nil,
                                          additionalAcceptableStatusCodes: IndexSet?,
                                          success: @escaping ((responseObject: T?, statusCode: Int?)) -> Void,
                                          failure: @escaping (_ error: Error) -> Void,
                                          apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil) {

        AF
            .request(URL, method: .get, parameters: parameters, headers: headers)
            .validate(statusCode: getAcceptableStatusCodes(additionalStatusCodes: additionalAcceptableStatusCodes))
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

    internal func postResponse<T: Codable>(forURL URL: String,
                                           headers: HTTPHeaders?,
                                           withParameters parameters: Parameters?,
                                           additionalAcceptableStatusCodes: IndexSet?,
                                           success: @escaping ((responseObject: T?, statusCode: Int?)) -> Void,
                                           failure: @escaping (_ error: Error) -> Void,
                                           apiFailure: ((_ errorResponse: ErrorResponse) -> Void)? = nil) {

        AF
            .request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: getAcceptableStatusCodes(additionalStatusCodes: additionalAcceptableStatusCodes))
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
