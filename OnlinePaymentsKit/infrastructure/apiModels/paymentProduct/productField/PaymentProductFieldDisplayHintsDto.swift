/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation

internal struct PaymentProductFieldDisplayHintsDto: Codable {
    let alwaysShow: Bool?
    let displayOrder: Int?
    let formElement: FormElementDto?
    let label: String?
    let link: String?
    let mask: String?
    let obfuscate: Bool?
    let placeholderLabel: String?
    let preferredInputType: String?
    let tooltip: ToolTipDto?
}
