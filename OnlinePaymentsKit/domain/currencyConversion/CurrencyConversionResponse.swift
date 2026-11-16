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

import Foundation

/// The response of a currency conversion quote request.
///
/// The API only sends a `proposal` and a `dccSessionId` when `result.result` is `.allowed`. For every other
/// result the response still decodes, and `proposal` and `dccSessionId` hold placeholder values (a proposal
/// with zero amounts and the currency code `UNKNOWN`, and an empty string). Always check `result.result` first,
/// and read the offer through `proposalOrNil` and `dccSessionIdOrNil`, which are `nil` when the API sent no data.
@objc(OPCurrencyConversionResponse) public class CurrencyConversionResponse: NSObject, Codable {
    @objc public var result: CurrencyConversionResult

    private var dccSessionIdStorage: String?
    private var proposalStorage: DccProposal?

    /// The currency conversion session ID, or an empty string when the API sent none.
    /// Use `dccSessionIdOrNil` to tell the two cases apart.
    @objc public var dccSessionId: String {
        get { dccSessionIdStorage ?? "" }
        set { dccSessionIdStorage = newValue }
    }

    /// The offered conversion, or a placeholder (zero amounts, currency code `UNKNOWN`) when the API sent none.
    /// Use `proposalOrNil` to tell the two cases apart.
    @objc public var proposal: DccProposal {
        get { proposalStorage ?? DccProposal.absent() }
        set { proposalStorage = newValue }
    }

    /// The `dccSessionId`, or `nil` when the API sent none or an empty one.
    @objc public var dccSessionIdOrNil: String? {
        guard let dccSessionIdStorage = dccSessionIdStorage, !dccSessionIdStorage.isEmpty else {
            return nil
        }

        return dccSessionIdStorage
    }

    /// The `proposal`, or `nil` when the API sent none (the result is not `.allowed`).
    @objc public var proposalOrNil: DccProposal? {
        return proposalStorage
    }

    private enum CodingKeys: String, CodingKey {
        case dccSessionId, result, proposal
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.result = try container.decode(CurrencyConversionResult.self, forKey: .result)
        self.dccSessionIdStorage = try? container.decodeIfPresent(String.self, forKey: .dccSessionId)
        self.proposalStorage = try? container.decodeIfPresent(DccProposal.self, forKey: .proposal)

        super.init()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(result, forKey: .result)
        try? container.encodeIfPresent(dccSessionIdStorage, forKey: .dccSessionId)
        try? container.encodeIfPresent(proposalStorage, forKey: .proposal)
    }
}
