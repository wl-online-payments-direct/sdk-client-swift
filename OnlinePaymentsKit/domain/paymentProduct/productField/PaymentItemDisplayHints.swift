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

import UIKit

@objc(OPPaymentItemDisplayHints) public class PaymentItemDisplayHints: NSObject, Codable {

    @objc public var displayOrder: Int
    @objc public var label: String?
    @objc public var logoPath: String
    @objc public var logoImage: UIImage?

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
