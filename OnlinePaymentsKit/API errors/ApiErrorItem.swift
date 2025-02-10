//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 18/07/2023
// Copyright © 2023 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPApiErrorItem)
public class ApiErrorItem: NSObject, Codable {
    @objc public let errorCode: String
    @objc public let category: String?
    @objc public let httpStatusCode: NSNumber?
    @objc public let id: String?
    @objc public let message: String
    @objc public let propertyName: String?
    @objc public let retriable: Bool

    private enum CodingKeys: String, CodingKey {
        case errorCode, category, code, httpStatusCode, id, message, propertyName, retriable
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.errorCode = try container.decode(String.self, forKey: .errorCode)

        self.category = try? container.decodeIfPresent(String.self, forKey: .category)

        if let httpStatusCodeNSNumber = try? container.decodeIfPresent(Int.self, forKey: .httpStatusCode) {
            self.httpStatusCode = httpStatusCodeNSNumber as NSNumber?
        } else {
            self.httpStatusCode = nil
        }

        self.id = try? container.decodeIfPresent(String.self, forKey: .id)
        self.message =
            (try? container.decodeIfPresent(String.self, forKey: .message)) ?? "This error does not contain a message"
        self.propertyName = try? container.decodeIfPresent(String.self, forKey: .propertyName)
        self.retriable = (try? container.decodeIfPresent(Bool.self, forKey: .retriable)) ?? true
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(errorCode, forKey: .errorCode)
        try? container.encodeIfPresent(category, forKey: .category)
        try? container.encodeIfPresent(httpStatusCode?.intValue, forKey: .httpStatusCode)
        try? container.encodeIfPresent(id, forKey: .id)
        try? container.encodeIfPresent(message, forKey: .message)
        try? container.encodeIfPresent(propertyName, forKey: .propertyName)
        try? container.encodeIfPresent(retriable, forKey: .retriable)
    }
}
