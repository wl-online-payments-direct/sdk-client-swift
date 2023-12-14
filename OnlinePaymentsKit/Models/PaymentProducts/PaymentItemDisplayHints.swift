//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import UIKit

@objc(OPPaymentItemDisplayHints)
public class PaymentItemDisplayHints: NSObject, Codable {

    @objc public var displayOrder: Int
    @objc public var label: String?
    @objc public var logoPath: String
    @objc public var logoImage: UIImage?

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    @objc required public init?(json: [String: Any]) {
        if let input = json["label"] as? String {
            label = input
        }

        guard let logoPath = json["logo"] as? String else {
            return nil
        }
        self.logoPath = logoPath

        guard let displayOrder = json["displayOrder"] as? Int else {
            return nil
        }
        self.displayOrder = displayOrder
    }

    private enum CodingKeys: String, CodingKey {
        case displayOrder, label, logo
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.displayOrder = try container.decodeIfPresent(Int.self, forKey: .displayOrder) ?? 0
        self.label = try? container.decodeIfPresent(String.self, forKey: .label)
        self.logoPath = try container.decode(String.self, forKey: .logo)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(displayOrder, forKey: .displayOrder)
        try? container.encodeIfPresent(label, forKey: .label)
        try? container.encodeIfPresent(logoPath, forKey: .logo)
    }

    internal override init() {
        self.displayOrder = 0
        self.logoPath = ""
        super.init()
    }

}
