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

#if canImport(PassKit)
    import PassKit
#endif

public class PaymentProductService: PaymentProductServiceProtocol {

    private let apiClient: ApiClientProtocol
    private let cacheManager: CacheManagerProtocol
    private let sessionData: SessionData

    internal init(
        apiClient: ApiClientProtocol,
        cacheManager: CacheManagerProtocol,
        sessionData: SessionData
    ) {
        self.apiClient = apiClient
        self.cacheManager = cacheManager
        self.sessionData = sessionData
    }

    public func paymentProducts(
        forContext context: PaymentContext,
        success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void,
        failure: @escaping (_ error: SdkError) -> Void,
    ) {
        let cacheKey = cacheManager.createCacheKey(
            prefix: "getPaymentProducts",
            suffix: nil,
            context: context
        )

        if let cached: BasicPaymentProducts = cacheManager.get(key: cacheKey) {
            success(cached)
            return
        }

        var params = buildParameters(for: context)
        params["hide"] = "fields"

        apiClient.get(
            path: "/products",
            parameters: params,
            version: .v1,
            additionalAcceptableStatusCodes: nil,
            success: { (responseObject: BasicPaymentProductsDto?, statusCode) in
                let strongSelf = self

                let factory = PaymentProductFactory()
                guard let basicPaymentProducts = factory.createBasicPaymentProducts(from: responseObject) else {
                    let error = ResponseError(
                        httpStatusCode: statusCode,
                        message: "Could not fetch BasicPaymentProducts"
                    )
                    failure(error)
                    return
                }

                validateResponse(
                    basicPaymentProducts,
                    statusCode: statusCode,
                    message: "Could not fetch BasicPaymentProducts",
                    success: { validatedBasicPaymentProducts in
                        validatedBasicPaymentProducts.paymentProducts = validatedBasicPaymentProducts.paymentProducts
                            .filter {
                                SupportedProductsUtil.isSupportedInSdk($0.id)
                            }

                        strongSelf.checkApplePayAvailability(
                            with: validatedBasicPaymentProducts,
                            for: context,
                            success: { products in
                                strongSelf.setLogoForPaymentProducts(for: products.paymentProducts) {
                                    strongSelf.cacheManager.set(key: cacheKey, value: products)
                                    success(products)
                                }
                            },
                            failure: failure
                        )
                    },
                    failure: failure
                )

            },
            failure: { error in
                failure(error)
            }
        )
    }

    public func paymentProduct(
        withId productId: Int,
        forContext context: PaymentContext,
        success: @escaping (_ paymentProduct: PaymentProduct) -> Void,
        failure: @escaping (_ error: SdkError) -> Void,
    ) {
        if !SupportedProductsUtil.isSupportedInSdk(productId) {
            let error = ResponseError(
                httpStatusCode: 404,
                message: "Product not found or not available.",
                data: SupportedProductsUtil.get404Error()
            )
            failure(error)
            return

        }

        let cacheKey = cacheManager.createCacheKey(
            prefix: "getPaymentProduct-\(productId)",
            suffix: nil,
            context: context
        )

        if let cached: PaymentProduct = cacheManager.get(key: cacheKey) {
            success(cached)
            return
        }

        let params = buildParameters(for: context)

        apiClient.get(
            path: "/products/\(productId)",
            parameters: params,
            version: .v1,
            additionalAcceptableStatusCodes: nil,
            success: { (responseObject: PaymentProductDto?, statusCode) in
                let strongSelf = self

                let factory = PaymentProductFactory()
                guard let responseObject = responseObject else {
                    let error = ResponseError(
                        httpStatusCode: statusCode,
                        message: "Could not fetch PaymentProduct."
                    )
                    failure(error)
                    return
                }

                let paymentProduct = factory.createPaymentProduct(from: responseObject)

                validateResponse(
                    paymentProduct,
                    statusCode: statusCode,
                    message: "Could not fetch PaymentProduct.",
                    success: { validatedProduct in
                        strongSelf.fixProductFieldsIfRequired(validatedProduct, productId: productId)
                        strongSelf.cacheManager.set(key: cacheKey, value: validatedProduct)

                        success(validatedProduct)
                    },
                    failure: failure
                )
            },
            failure: failure,
        )
    }

    public func paymentProductNetworks(
        forProductId productId: Int,
        forContext context: PaymentContext,
        success: @escaping (_ networks: PaymentProductNetworks) -> Void,
        failure: @escaping (_ error: SdkError) -> Void,
    ) {
        let cacheKey = cacheManager.createCacheKey(
            prefix: "getPaymentProductNetworks-\(productId)",
            suffix: nil,
            context: context
        )

        if let cached: PaymentProductNetworks = cacheManager.get(key: cacheKey) {
            success(cached)
            return
        }

        let params = buildParameters(for: context)

        apiClient.get(
            path: "/products/\(productId)/networks",
            parameters: params,
            version: .v1,
            additionalAcceptableStatusCodes: nil,
            success: { (responseObject: PaymentProductNetworks?, statusCode) in
                let strongSelf = self

                validateResponse(
                    responseObject,
                    statusCode: statusCode,
                    message: "Could not fetch PaymentProductNetworks.",
                    success: { validatedProductNetwork in
                        strongSelf.cacheManager.set(key: cacheKey, value: validatedProductNetwork)
                        success(validatedProductNetwork)
                    },
                    failure: failure
                )
            },
            failure: { error in
                failure(error)
            }
        )
    }

    public func checkAvailability(
        forProduct paymentProductId: Int,
        context: PaymentContext,
        success: @escaping () -> Void,
        failure: @escaping (_ error: SdkError) -> Void,
    ) {
        if paymentProductId == SupportedProductsUtil.kApplePayIdentifier {
            #if canImport(PassKit)
                if PKPaymentAuthorizationViewController.canMakePayments() {
                    paymentProductNetworks(
                        forProductId: SupportedProductsUtil.kApplePayIdentifier,
                        forContext: context,
                        success: { (_ paymentProductNetworks: PaymentProductNetworks) -> Void in
                            if !PKPaymentAuthorizationViewController.canMakePayments(
                                usingNetworks: paymentProductNetworks.paymentProductNetworks
                            ) {
                                let error = ResponseError(
                                    httpStatusCode: 400,
                                    message: "Product not found or not available."
                                )
                                failure(error)
                            } else {
                                success()
                            }
                        },
                        failure: failure,
                    )
                } else {
                    let error = ResponseError(
                        httpStatusCode: 400,
                        message: "Product not found or not available.",
                        data: SupportedProductsUtil.get404Error()
                    )
                    failure(error)
                }
            #else
                let error = ResponseError(
                    httpStatusCode: 400,
                    message: "Product not found or not available.",
                    data: SupportedProductsUtil.get404Error()
                )
                failure(error)
            #endif
        } else if !SupportedProductsUtil.isSupportedInSdk(paymentProductId) {
            let error = ResponseError(
                httpStatusCode: 404,
                message: "Product not found or not available.",
                data: SupportedProductsUtil.get404Error()
            )
            failure(error)
        } else {
            success()
        }
    }

    private func buildParameters(for context: PaymentContext) -> [String: Any] {
        return [
            "countryCode": context.countryCode,
            "currencyCode": context.amountOfMoney.currencyCode,
            "amount": context.amountOfMoney.amount,
            "isRecurring": context.isRecurring ? "true" : "false",
        ]
    }

    private func checkApplePayAvailability(
        with paymentProducts: BasicPaymentProducts,
        for context: PaymentContext,
        success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void,
        failure: @escaping (SdkError) -> Void,
    ) {
        if let applePayPaymentProduct = paymentProducts.paymentProduct(
            withId: SupportedProductsUtil.kApplePayIdentifier
        ) {
            if SupportedProductsUtil.systemVersionGreaterThanOrEqualTo("8.0")
                && PKPaymentAuthorizationViewController.canMakePayments()
            {
                paymentProductNetworks(
                    forProductId: SupportedProductsUtil.kApplePayIdentifier,
                    forContext: context,
                    success: { (_ paymentProductNetworks: PaymentProductNetworks) -> Void in
                        if let product = paymentProducts.paymentProducts.firstIndex(of: applePayPaymentProduct),
                            !PKPaymentAuthorizationViewController.canMakePayments(
                                usingNetworks: paymentProductNetworks.paymentProductNetworks
                            )
                        {
                            paymentProducts.paymentProducts.remove(at: product)
                        }
                        success(paymentProducts)
                    },
                    failure: failure,
                )
            } else {
                if let product = paymentProducts.paymentProducts.firstIndex(of: applePayPaymentProduct) {
                    paymentProducts.paymentProducts.remove(at: product)
                }
                success(paymentProducts)
            }
        } else {
            success(paymentProducts)
        }
    }

    private func fixProductFieldsIfRequired(_ product: PaymentProduct, productId: Int) {
        let EXPIRY_DATE_MASK = "{{99}}/{{99}}"
        let REGULAR_CARD_NUMBER_MASK = "{{9999}} {{9999}} {{9999}} {{9999}}"
        let AMEX_CARD_NUMBER_MASK = "{{9999}} {{999999}} {{99999}}"
        let AMEX_PRODUCT_ID = 2

        for field in product.fields {
            switch field.id {
            case "expiryDate":
                if field.displayHints.formElement.type == .listType {
                    field.displayHints.formElement.type = .textType
                }

                if field.displayHints.mask == nil || field.displayHints.mask?.isEmpty == true {
                    field.displayHints.mask = EXPIRY_DATE_MASK
                }

            case "cardNumber":
                if field.displayHints.mask == nil || field.displayHints.mask?.isEmpty == true {
                    let mask = productId == AMEX_PRODUCT_ID ? AMEX_CARD_NUMBER_MASK : REGULAR_CARD_NUMBER_MASK
                    field.displayHints.mask = mask
                }

            default:
                break
            }
        }
    }

    private func setLogoForPaymentProducts(
        for products: [BasicPaymentProduct],
        completion: @escaping () -> Void
    ) {
        guard !products.isEmpty else {
            completion()
            return
        }

        var counter = 0

        for product in products {
            if let logoPath = product.logo {
                getLogoByStringURL(from: logoPath) { data, _, error in
                    counter += 1
                    if let imageData = data, error == nil {
                        product.updateLogoImage(UIImage(data: imageData))
                    }

                    if counter == products.count {
                        completion()
                    }
                }
            } else {
                counter += 1
                if counter == products.count {
                    completion()
                }
            }
        }
    }

    internal func getLogoByStringURL(
        from url: String,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        guard let encodedUrlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            Logger.log("Unable to decode URL for url string: \(url)")
            completion(nil, nil, nil)
            return
        }

        guard let encodedUrl = URL(string: encodedUrlString) else {
            Logger.log("Unable to create URL for url string: \(encodedUrlString)")
            completion(nil, nil, nil)
            return
        }

        URLSession.shared.dataTask(
            with: encodedUrl,
            completionHandler: { data, response, error in
                DispatchQueue.main.async {
                    completion(data, response, error)
                }
            }
        ).resume()
    }
}
