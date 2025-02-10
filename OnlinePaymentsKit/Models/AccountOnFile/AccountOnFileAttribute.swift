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

    private enum CodingKeys: String, CodingKey {
        case key, value, status
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try container.decode(String.self, forKey: .key)
        self.value = try? container.decodeIfPresent(String.self, forKey: .value)

        super.init()

        let statusString = try? container.decodeIfPresent(String.self, forKey: .status)
        self.status = self.getAccountOnFileAttributeStatus(status: statusString)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(key, forKey: .key)
        try? container.encodeIfPresent(value, forKey: .value)
        try? container.encode(getAccountOnFileAttributeString(status: status), forKey: .status)
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
            Logger.log("AccountOnFileAttribute status: \(status ?? "") is invalid")
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
