//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPAccountOnFileAttribute)
public class AccountOnFileAttribute: NSObject, Codable {

    @objc public var key: String
    @objc public var value: String?
    @objc public var status: AccountOnFileAttributeStatus = .readOnly
    @available(
        *,
        deprecated,
        message: "In a future release, this property will be removed since it is not returned from the API."
    )
    @objc public var mustWriteReason: String?

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    @objc required public init?(json: [String: Any]) {
        guard let key = json["key"] as? String else {
            return nil
        }
        self.key = key
        value = json["value"] as? String
        mustWriteReason = json["mustWriteReason"] as? String

        switch json["status"] as? String {
        case "READ_ONLY"?:
            status = .readOnly
        case "CAN_WRITE"?:
            status = .canWrite
        case "MUST_WRITE"?:
            status = .mustWrite
        default:
            Macros.DLog(message: "AccountOnFileAttribute status: \(json["status"]!) is invalid")
            return nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case key, value, status, mustWriteReason
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try container.decode(String.self, forKey: .key)
        self.value = try? container.decodeIfPresent(String.self, forKey: .value)
        self.mustWriteReason = try? container.decodeIfPresent(String.self, forKey: .mustWriteReason)

        super.init()

        let statusString = try? container.decodeIfPresent(String.self, forKey: .status)
        self.status = self.getAccountOnFileAttributeStatus(status: statusString)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(key, forKey: .key)
        try? container.encodeIfPresent(value, forKey: .value)
        try? container.encode(getAccountOnFileAttributeString(status: status), forKey: .status)
        try? container.encodeIfPresent(mustWriteReason, forKey: .mustWriteReason)
    }

    private func getAccountOnFileAttributeStatus(status: String?) -> AccountOnFileAttributeStatus {
        switch status {
        case "READ_ONLY":
            return .readOnly
        case "CAN_WRITE":
            return .canWrite
        case "MUST_WRITE":
            return .mustWrite
        default:
            Macros.DLog(message: "AccountOnFileAttribute status: \(status ?? "") is invalid")
            return .readOnly
        }
    }

    private func getAccountOnFileAttributeString(status: AccountOnFileAttributeStatus) -> String {
        switch status {
        case .readOnly:
            return "READ_ONLY"
        case .canWrite:
            return "CAN_WRITE"
        case .mustWrite:
            return "MUST_WRITE"
        }
    }

    public func isEditingAllowed() -> Bool {
        status != .readOnly
    }
}
