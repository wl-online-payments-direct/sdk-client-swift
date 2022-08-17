//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

@objc(OPSession)
public class Session: NSObject {
    @objc public var communicator: C2SCommunicator
    @objc public var assetManager: AssetManager
    @objc public var encryptor: Encryptor
    @objc public var joseEncryptor: JOSEEncryptor
    @objc public var stringFormatter: StringFormatter
    
    @objc public var paymentProducts = BasicPaymentProducts()
    
    @objc public var paymentProductMapping = [AnyHashable: Any]()
    
    @objc public var baseURL: String {
        return communicator.baseURL
    }
    
    @objc public var assetsBaseURL: String{
        return communicator.assetsBaseURL
    }
    
    @objc public var iinLookupPending = false
    
    @objc public init(communicator: C2SCommunicator, assetManager: AssetManager, encryptor: Encryptor, JOSEEncryptor: JOSEEncryptor, stringFormatter: StringFormatter) {
        self.communicator = communicator
        self.assetManager = assetManager
        self.encryptor = encryptor
        self.joseEncryptor = JOSEEncryptor
        self.stringFormatter = stringFormatter
    }
    
    @objc public init(clientSessionId: String, customerId: String, baseURL: String, assetBaseURL: String, appIdentifier: String) {
        let assetManager = AssetManager()
        let stringFormatter = StringFormatter()
        let encryptor = Encryptor()
        let configuration = C2SCommunicatorConfiguration(clientSessionId: clientSessionId,
                                                         customerId: customerId,
                                                         baseURL: baseURL,
                                                         assetBaseURL: assetBaseURL,
                                                         appIdentifier: appIdentifier)
        let communicator = C2SCommunicator(configuration: configuration)
        let jsonEncryptor = JOSEEncryptor(encryptor: encryptor)
        
        self.communicator = communicator
        self.assetManager = assetManager
        self.encryptor = encryptor
        self.joseEncryptor = jsonEncryptor
        self.stringFormatter = stringFormatter
    }
    
    @objc public static func session(clientSessionId: String, customerId: String, baseURL: String, assetBaseURL: String, appIdentifier: String) -> Session {
        return Session.init(clientSessionId: clientSessionId, customerId: customerId, baseURL: baseURL, assetBaseURL: assetBaseURL, appIdentifier: appIdentifier)
    }
    
    @objc public func paymentProducts(for context: PaymentContext, success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void, failure: @escaping (_ error: Error) -> Void) {
        communicator.paymentProducts(forContext: context, success: { paymentProducts in
            self.paymentProducts = paymentProducts
            self.paymentProducts.stringFormatter = self.stringFormatter
            self.assetManager.initializeImages(for: paymentProducts.paymentProducts)
            self.setLogoForPaymentItems(for: paymentProducts.paymentProducts){
                success(paymentProducts)
            }
        }, failure: failure)
    }
    
    @objc public func paymentProductNetworks(forProductId paymentProductId: String, context: PaymentContext, success: @escaping (_ paymentProductNetworks: PaymentProductNetworks) -> Void, failure: @escaping (_ error: Error) -> Void) {
        communicator.paymentProductNetworks(forProduct: paymentProductId, context: context, success: { paymentProductNetworks in
            success(paymentProductNetworks)
        }, failure: { error in
            failure(error)
        })
    }
    
    @objc(paymentItemsForContext:groupPaymentProducts:success:failure:)
    public func paymentItems(for context: PaymentContext, groupPaymentProducts: Bool, success: @escaping (_ paymentItems: PaymentItems) -> Void, failure: @escaping (_ error: Error) -> Void) {
        communicator.paymentProducts(forContext: context, success: { paymentProducts in
            if paymentProducts.paymentProducts.isEmpty {
                let items = PaymentItems(products: paymentProducts, groups: nil)
                success(items)
            }
            self.paymentProducts = paymentProducts
            self.paymentProducts.stringFormatter = self.stringFormatter
            self.assetManager.initializeImages(for: paymentProducts.paymentProducts)
            self.setLogoForPaymentItems(for: paymentProducts.paymentProducts){
                let items = PaymentItems(products: paymentProducts, groups: nil)
                success(items)
            }
        }, failure: failure)
    }
    
    @objc public func paymentProduct(withId paymentProductId: String, context: PaymentContext, success: @escaping (_ paymentProduct: PaymentProduct) -> Void, failure: @escaping (_ error: Error) -> Void) {
        let key = "\(paymentProductId)-\(context.description)"
        
        if let paymentProduct = paymentProductMapping[key] as? PaymentProduct {
            success(paymentProduct)
        } else {
            communicator.paymentProduct(withIdentifier: paymentProductId, context: context, success: { paymentProduct in
                self.paymentProductMapping[key] = paymentProduct
                self.assetManager.initializeImages(for: paymentProduct)
                self.setLogoForDisplayHints(for: paymentProduct.displayHints) {}
                self.setLogoForDisplayHintsList(for: paymentProduct.displayHintsList){
                    success(paymentProduct)
                }
            }, failure: failure)
        }
    }
    
    @objc(IINDetailsForPartialCreditCardNumber:context:success:failure:)
    public func iinDetails(forPartialCreditCardNumber partialCreditCardNumber: String,
                           context: PaymentContext?,
                           success: @escaping (_ iinDetailsResponse: IINDetailsResponse) -> Void,
                           failure: @escaping (_ error: Error) -> Void) {
        if partialCreditCardNumber.count < 6 {
            let response = IINDetailsResponse(status: .notEnoughDigits)
            success(response)
        } else {
            iinLookupPending = true
            communicator.paymentProductId(byPartialCreditCardNumber: partialCreditCardNumber, context: context, success: { response in
                self.iinLookupPending = false
                success(response)
            }, failure: { error in
                self.iinLookupPending = false
                failure(error)
            })
        }
        
    }
    
    @objc(preparePaymentRequest:success:failure:)
    public func prepare(_ paymentRequest: PaymentRequest, success: @escaping (_ preparedPaymentRequest: PreparedPaymentRequest) -> Void, failure: @escaping (_ error: Error) -> Void) {
        communicator.publicKey(success: { publicKeyResponse in
            let publicKeyAsData = publicKeyResponse.encodedPublicKey.decode()
            guard let strippedPublicKeyAsData = self.encryptor.stripPublicKey(data: publicKeyAsData) else {
                failure(SessionError.RuntimeError("Failed to decode Public key."))
                return
            }
            let tag = "globalcollect-sdk-public-key-swift"
            
            self.encryptor.deleteRSAKey(withTag: tag)
            self.encryptor.storePublicKey(publicKey: strippedPublicKeyAsData, tag: tag)
            
            guard let publicKey = self.encryptor.RSAKey(withTag: tag) else {
                failure(SessionError.RuntimeError("Failed to find RSA Key."))
                return
            }
            
            let paymentRequestJSON = self.preparePaymentRequestJSON(forClientSessionId: self.clientSessionId, paymentRequest: paymentRequest)
            let encryptedFields = self.joseEncryptor.encryptToCompactSerialization(JSON: paymentRequestJSON, withPublicKey: publicKey, keyId: publicKeyResponse.keyId)
            let encodedClientMetaInfo = self.communicator.base64EncodedClientMetaInfo
            let preparedRequest = PreparedPaymentRequest(encryptedFields: encryptedFields, encodedClientMetaInfo: encodedClientMetaInfo)
            
            success(preparedRequest)
        }, failure: { error in
            failure(error)
        })
    }
    
    private func preparePaymentRequestJSON(forClientSessionId clientSessionId: String, paymentRequest: PaymentRequest) -> String {
        var paymentRequestJSON = String()
        
        guard let paymentProduct = paymentRequest.paymentProduct else {
            NSException(name: NSExceptionName(rawValue: "Invalid payment product"), reason: "Payment product is invalid").raise()
            //Return is mandatory but will never be reached because of the exception above.
            return "Invalid payment product"
        }
        
        let clientSessionId = "{\"clientSessionId\": \"\(clientSessionId)\", "
        paymentRequestJSON += clientSessionId
        let nonce = "\"nonce\": \"\(self.encryptor.generateUUID())\", "
        paymentRequestJSON += nonce
        let paymentProductJSON = "\"paymentProductId\": \(paymentProduct.identifier), "
        paymentRequestJSON += paymentProductJSON
        
        if let accountOnFile = paymentRequest.accountOnFile {
            paymentRequestJSON += "\"accountOnFileId\": \(accountOnFile.identifier), "
        }
        if paymentRequest.tokenize {
            let tokenize = "\"tokenize\": true, "
            paymentRequestJSON += tokenize
        }
        if let fieldVals = paymentRequest.unmaskedFieldValues, let values = self.keyValueJSONFromDictionary(dictionary: fieldVals) {
            let paymentValues = "\"paymentValues\": \(values)}"
            paymentRequestJSON += paymentValues
        }
        
        return paymentRequestJSON
    }
    
    @objc public var clientSessionId: String {
        return communicator.clientSessionId
    }
    
    @objc public func keyValuePairs(from dictionary: [String: String]) -> [[String: String]] {
        var keyValuePairs = [[String: String]]()
        for (key, value) in  dictionary {
            let pair = ["key": key, "value": value]
            keyValuePairs.append(pair)
        }
        return keyValuePairs
    }
    
    @objc public func keyValueJSONFromDictionary(dictionary: [String: String]) -> String? {
        let keyValuePairs = self.keyValuePairs(from: dictionary)
        guard let JSONAsData = try? JSONSerialization.data(withJSONObject: keyValuePairs) else {
            Macros.DLog(message: "Unable to create JSON data from dictionary")
            return nil
        }
        
        return String(bytes: JSONAsData, encoding: String.Encoding.utf8)
    }
    
    
    private func setLogoForPaymentItems(for paymentItems: [BasicPaymentItem], completion: @escaping() -> Void){
        var counter = 0;
        for paymentItem in paymentItems {
            setLogoForDisplayHints(for: paymentItem.displayHints, completion: {})
            if (paymentItem.displayHintsList.isEmpty == false) {
                setLogoForDisplayHintsList(for: paymentItem.displayHintsList, completion: {
                    counter += 1
                    if (counter == paymentItems.count) {
                        completion()
                    }
                })
            } else {
                counter += 1
                if (counter == paymentItems.count) {
                    completion()
                }
            }
        }
    }
    
    internal func setLogoForDisplayHints(for displayHints: PaymentItemDisplayHints, completion: @escaping() -> Void) {
        assetManager.getLogoByStringURL(from: displayHints.logoPath) { data, response, error in
            if let imageData = data, error == nil {
                displayHints.logoImage = UIImage(data: imageData)
            }
            completion()
        }
    }
    
    internal func setLogoForDisplayHintsList(for displayHints: [PaymentItemDisplayHints], completion: @escaping() -> Void){
        var counter = 0;
        for displayHint in displayHints {
            assetManager.getLogoByStringURL(from: displayHint.logoPath) { data, response, error in
                counter += 1
                if let imageData = data, error == nil {
                    displayHint.logoImage = UIImage(data: imageData)
                }
                if(counter == displayHints.count) {
                    completion()
                }
            }
        }
    }
}
