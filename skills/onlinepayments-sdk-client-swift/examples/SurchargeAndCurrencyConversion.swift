import Foundation
import OnlinePaymentsKit

// [START card-reference]
/// What identifies the card for a surcharge or currency conversion request. These requests are not encrypted:
/// for a card being entered send only its first 8 digits (at least 6) with the payment product id, never the full
/// number. For a stored card send the account on file's id.
enum CardReference {
    case entered(cardNumber: String, productId: Int)
    case stored(accountOnFileId: String)
}

private func firstDigits(of cardNumber: String) -> String {
    String(cardNumber.filter { $0.isNumber }.prefix(8))
}
// [END card-reference]

// [START surcharge-calculation]
struct SurchargeOffer {
    let surchargeAmount: AmountOfMoney
    let totalAmount: AmountOfMoney
}

/// Only when your merchant account has surcharging enabled. The payment context keeps the net amount; the platform
/// adds the surcharge when your backend creates the payment with order.surchargeSpecificInput.mode set to
/// "on-behalf-of". Returns nil when no surcharge applies.
func loadSurcharge(
    sdk: OnlinePaymentsSdk,
    amount: AmountOfMoney,
    card: CardReference
) async throws -> SurchargeOffer? {
    let response: SurchargeCalculationResponse
    switch card {
    case let .entered(cardNumber, productId):
        response = try await sdk.fetchSurcharge(
            amount: amount,
            partialCardNumber: firstDigits(of: cardNumber),
            paymentProductId: productId
        )
    case let .stored(accountOnFileId):
        response = try await sdk.fetchSurcharge(amount: amount, token: accountOnFileId)
    }

    // The API leaves the amounts out when no surcharge applies. Read the result first, and the amounts through
    // the ...OrNil properties, which are nil when the API sent nothing.
    guard let surcharge = response.surcharges.first,
        surcharge.result == .ok,
        let surchargeAmount = surcharge.surchargeAmountOrNil,
        let totalAmount = surcharge.totalAmountOrNil
    else {
        return nil
    }

    return SurchargeOffer(surchargeAmount: surchargeAmount, totalAmount: totalAmount)
}
// [END surcharge-calculation]

// [START currency-conversion]
struct CurrencyOffer {
    let dccSessionId: String
    let merchantAmount: AmountOfMoney // in your currency
    let cardAmount: AmountOfMoney // in the card's currency
    let exchangeRate: Double
    let markUpPercent: Double // 3.12 means 3.12 %
    let disclaimer: String? // show it next to the two options
}

/// Only when your merchant account has dynamic currency conversion enabled (Visa and Mastercard only). A card that
/// cannot be converted gets no offer: the result is not .allowed, or the call fails with HTTP 404. Returns nil then.
func loadCurrencyOffer(
    sdk: OnlinePaymentsSdk,
    amount: AmountOfMoney,
    card: CardReference
) async throws -> CurrencyOffer? {
    let response: CurrencyConversionResponse
    do {
        switch card {
        case let .entered(cardNumber, productId):
            response = try await sdk.fetchCurrencyConversionQuote(
                amount: amount,
                partialCardNumber: firstDigits(of: cardNumber),
                paymentProductId: productId
            )
        case let .stored(accountOnFileId):
            response = try await sdk.fetchCurrencyConversionQuote(amount: amount, token: accountOnFileId)
        }
    } catch let error as ResponseError where error.httpStatusCode == 404 {
        return nil // the card cannot be converted: no offer
    }

    // When the result is not .allowed the API sends no proposal and an empty dccSessionId. Check the result
    // first, and read both through the ...OrNil properties.
    guard response.result.result == .allowed,
        let proposal = response.proposalOrNil,
        let dccSessionId = response.dccSessionIdOrNil
    else {
        return nil
    }

    return CurrencyOffer(
        dccSessionId: dccSessionId,
        merchantAmount: proposal.baseAmount,
        cardAmount: proposal.targetAmount,
        exchangeRate: proposal.rate.exchangeRate,
        markUpPercent: proposal.rate.markUpRate,
        disclaimer: proposal.disclaimerDisplay
    )
}
// [END currency-conversion]

// [START currency-conversion-choice]
/// Call this when the customer has actively chosen one of the two equal options (no option preselected, no
/// yes/no question). Send the result with the payment: both values are mandatory once a quote was shown, also
/// when the customer keeps your currency (payInCardCurrency false). If the customer declined the offer, do not
/// offer it again in this checkout.
func chooseCurrency(offer: CurrencyOffer, payInCardCurrency: Bool) -> CurrencyConversionChoice {
    CurrencyConversionChoice(dccSessionId: offer.dccSessionId, acceptedByUser: payInCardCurrency)
}
// [END currency-conversion-choice]

// [START surcharge-then-currency-conversion]
struct CheckoutOffers {
    let surcharge: SurchargeOffer?
    let currency: CurrencyOffer?
}

/// When surcharging and currency conversion both apply, calculate the surcharge first and request the currency
/// conversion quote for the surcharge's total amount (net amount plus surcharge). Without a surcharge, request it
/// for the order amount. The payment context keeps the net amount in both cases.
func loadOffers(sdk: OnlinePaymentsSdk, order: Order, card: CardReference) async throws -> CheckoutOffers {
    let orderAmount = AmountOfMoney(amount: order.amountInCents, currencyCode: order.currencyCode)

    let surcharge = try await loadSurcharge(sdk: sdk, amount: orderAmount, card: card)
    let amountToConvert = surcharge?.totalAmount ?? orderAmount
    let currency = try await loadCurrencyOffer(sdk: sdk, amount: amountToConvert, card: card)

    return CheckoutOffers(surcharge: surcharge, currency: currency)
}
// [END surcharge-then-currency-conversion]
