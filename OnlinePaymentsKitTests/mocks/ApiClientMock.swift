/*
 * Do not remove or alter the notices in this preamble.
 *
 * This software is owned by Worldline and may not be be altered, copied, reproduced, republished, uploaded, posted, transmitted or distributed in any way, without the prior written consent of Worldline.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Alamofire
import Foundation

@testable import OnlinePaymentsKit

class ApiClientMock: ApiClientProtocol {

    var getCallCount = 0
    var postCallCount = 0
    var lastGetPath: String?
    var lastPostPath: String?
    var lastGetParameters: Parameters?
    var lastPostParameters: Parameters?
    var lastPostAdditionalStatusCodes: IndexSet?

    var mockGetResponses: [String: Any] = [:]
    var mockGetStatusCode: Int = 200
    var shouldGetFail = false
    var mockGetError: SdkError?
    var shouldGetFailWithCommunicationError = false

    var mockPostResponses: [String: Any] = [:]
    var mockPostStatusCode: Int = 200
    var shouldPostFail = false
    var mockPostError: SdkError?
    var shouldPostFailWithCommunicationError = false

    func get<T: Codable>(
        path: String,
        parameters: Parameters?,
        version: ApiVersion,
        additionalAcceptableStatusCodes: IndexSet?,
        success: @escaping (T?, Int?) -> Void,
        failure: @escaping (SdkError) -> Void
    ) {
        getCallCount += 1
        lastGetPath = path
        lastGetParameters = parameters

        if shouldGetFailWithCommunicationError {
            let error = CommunicationError(message: "Mock communication error")
            failure(error)

            return
        }

        if shouldGetFail {
            let error =
                mockGetError
                ?? ResponseError(
                    httpStatusCode: 500,
                    message: "Mock error",
                    data: nil
                )
            failure(error)

            return
        }

        let response = mockGetResponses[path] as? T
        success(response, mockGetStatusCode)
    }

    func post<T: Codable>(
        path: String,
        parameters: Parameters?,
        version: ApiVersion,
        additionalAcceptableStatusCodes: IndexSet?,
        success: @escaping (T?, Int?) -> Void,
        failure: @escaping (SdkError) -> Void
    ) {
        postCallCount += 1
        lastPostPath = path
        lastPostParameters = parameters
        lastPostAdditionalStatusCodes = additionalAcceptableStatusCodes

        if shouldPostFailWithCommunicationError {
            let error = CommunicationError(message: "Mock communication error")
            failure(error)

            return
        }

        if shouldPostFail {
            let error =
                mockPostError
                ?? ResponseError(
                    httpStatusCode: 500,
                    message: "Mock error",
                    data: nil
                )
            failure(error)

            return
        }

        let response = mockPostResponses[path] as? T
        success(response, mockPostStatusCode)
    }
}
