//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 24.1.25.
// Copyright © 2025 Global Collect Services. All rights reserved.
// 


struct PaymentRequestData: Codable {
    let clientSessionId: String
    let nonce: String
    let paymentProductId: Int
    let accountOnFileId: Int?
    let tokenize: Bool?
    let paymentValues: [String: String]?
}