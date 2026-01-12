/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

internal import Alamofire
import Foundation

class ApiClient: ApiClientProtocol {

    private let sessionData: SessionData
    private let loggingEnabled: Bool
    private let util: MetadataUtil?
    private let apiClientSession: Session

    var headers: HTTPHeaders {
        return [
            "Authorization": "GCS v1Client:\(sessionData.clientSessionId)",
            "X-GCS-ClientMetaInfo": util?.base64EncodedClientMetaInfo ?? "",
        ]
    }

    init(
        sessionData: SessionData,
        loggingEnabled: Bool = false,
        util: MetadataUtil? = nil,
        session: Session = .default
    ) {
        self.sessionData = sessionData
        self.loggingEnabled = loggingEnabled
        self.util = util
        self.apiClientSession = session
    }

    func get<T: Codable>(
        path: String,
        parameters: Parameters? = nil,
        version: ApiVersion = .v1,
        additionalAcceptableStatusCodes: IndexSet? = nil,
        success: @escaping (T?, Int?) -> Void,
        failure: @escaping (SdkError) -> Void,
    ) {
        let url = buildUrl(path: path)

        if loggingEnabled {
            logRequest(forURL: url, requestMethod: .get)
        }

        apiClientSession.request(url, method: .get, parameters: parameters, headers: headers)
            .validate(statusCode: getAcceptableStatusCodes(additionalStatusCodes: additionalAcceptableStatusCodes))
            .responseDecodable(of: T.self) { [weak self] response in
                self?.handleResponse(response, forURL: url, success: success, failure: failure)
            }
    }

    func post<T: Codable>(
        path: String,
        parameters: Parameters?,
        version: ApiVersion = .v1,
        additionalAcceptableStatusCodes: IndexSet? = nil,
        success: @escaping (T?, Int?) -> Void,
        failure: @escaping (SdkError) -> Void,
    ) {
        let url = buildUrl(path: path)

        if loggingEnabled {
            logRequest(forURL: url, requestMethod: .post, postBody: parameters)
        }

        apiClientSession.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        .validate(statusCode: getAcceptableStatusCodes(additionalStatusCodes: additionalAcceptableStatusCodes))
        .responseDecodable(of: T.self) { [weak self] response in
            self?.handleResponse(response, forURL: url, success: success, failure: failure)
        }
    }

    private func handleResponse<T: Codable>(
        _ response: AFDataResponse<T>,
        forURL url: String,
        success: @escaping (T?, Int?) -> Void,
        failure: @escaping (SdkError) -> Void,
    ) {
        if let error = response.error {
            if error.responseCode != nil {
                let apiError = try? JSONDecoder().decode(ApiError.self, from: response.data ?? Data())
                let localizedDescription = error.localizedDescription

                let errorResponse: ErrorResponse? = apiError.map {
                    ErrorResponse(
                        errorId: $0.errorId,
                        errors: $0.errors
                    )
                }

                if loggingEnabled {
                    logApiFailureResponse(forURL: url, forApiResponseMessage: localizedDescription)
                }

                let responseError = ResponseError(
                    httpStatusCode: error.responseCode,
                    message: localizedDescription,
                    data: errorResponse
                )

                failure(responseError)
            } else {
                if loggingEnabled {
                    logCommunicationFailureResponse(forURL: url, forError: error)
                }

                failure(CommunicationError(message: "Communication error found."))
            }
        } else {
            if loggingEnabled {
                logSuccessResponse(
                    forURL: url,
                    withResponseCode: response.response?.statusCode,
                    forResponse: response.value
                )
            }

            success(response.value, response.response?.statusCode)
        }
    }

    private func getAcceptableStatusCodes(additionalStatusCodes: IndexSet?) -> [Int] {
        var codes = Array(200..<300)

        if let additional = additionalStatusCodes {
            codes.append(contentsOf: additional)
        }

        return codes
    }

    private func buildUrl(path: String, version: ApiVersion = .v1) -> String {
        return "\(sessionData.clientApiUrl)\(version.rawValue)\(sessionData.customerId)\(path)"
    }

    private func logRequest(forURL url: String, requestMethod: HTTPMethod, postBody: Parameters? = nil) {
        if !loggingEnabled {
            return
        }

        var requestLog =
            """
            Request URL : \(url)
            Request Method : \(requestMethod.rawValue)
            Request Headers : \n
            """

        headers.forEach { header in
            requestLog += " \(header) \n"
        }

        if requestMethod == .post, let postBody = postBody {
            requestLog += "Body: \(postBody.description)"
        }

        Logger.log(requestLog)
    }

    private func logSuccessResponse<T: Codable>(
        forURL url: String,
        withResponseCode responseCode: Int?,
        forResponse response: T?
    ) {
        if !loggingEnabled {
            return
        }

        guard let response = response,
            let responseData = try? JSONEncoder().encode(response)
        else {
            Logger.log("Success response received, but could not be encoded.")
            return
        }

        let responseString = String(decoding: responseData, as: UTF8.self)
        logResponse(forURL: url, responseCode: responseCode, responseBody: responseString)
    }

    private func logCommunicationFailureResponse(forURL url: String, forError error: Error) {
        logResponse(
            forURL: url,
            responseCode: error.asAFError?.responseCode,
            responseBody: "\(error.localizedDescription)",
            isCommunicationError: true
        )
    }

    private func logApiFailureResponse(forURL url: String, forApiResponseMessage message: String) {
        logResponse(
            forURL: url,
            responseCode: nil,
            responseBody: message,
            isApiError: true
        )
    }

    private func logResponse(
        forURL url: String,
        responseCode: Int?,
        responseBody: String,
        isCommunicationError: Bool = false,
        isApiError: Bool = false
    ) {
        if !loggingEnabled {
            return
        }

        var responseLog =
            """
            Response URL : \(url)
            Response Code :
            """

        if let responseCode = responseCode {
            responseLog += " \(responseCode) \n"
        } else {
            responseLog += " Nil \n"
        }

        responseLog += "Response Headers : \n"

        headers.forEach { header in
            responseLog += " \(header) \n"
        }

        if isApiError {
            responseLog += "API Error : "
        } else if isCommunicationError {
            responseLog += "Communication Error : "
        } else {
            responseLog += "Response Body : "
        }

        responseLog += responseBody

        Logger.log(responseLog)
    }
}
