//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

public class Session {
    public var communicator: C2SCommunicator
    public var assetManager: AssetManager
    public var encryptor: Encryptor
    public var joseEncryptor: JOSEEncryptor
    public var stringFormatter: StringFormatter
    
    public var paymentProducts = BasicPaymentProducts()
    
    public var paymentProductMapping = [AnyHashable: Any]()
    
    public var baseURL: String {
        return communicator.baseURL
    }
    
    public var assetsBaseURL: String{
        return communicator.assetsBaseURL
    }
    
    public var iinLookupPending = false
    
    public init(communicator: C2SCommunicator, assetManager: AssetManager, encryptor: Encryptor, JOSEEncryptor: JOSEEncryptor, stringFormatter: StringFormatter) {
        self.communicator = communicator
        self.assetManager = assetManager
        self.encryptor = encryptor
        self.joseEncryptor = JOSEEncryptor
        self.stringFormatter = stringFormatter
    }
    
    public init(clientSessionId: String, customerId: String, baseURL: String, assetBaseURL: String, appIdentifier: String) {
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
    
    public func paymentProducts(for context: PaymentContext, success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void, failure: @escaping (_ error: Error) -> Void) {
        communicator.paymentProducts(forContext: context, success: { paymentProducts in
            self.paymentProducts = paymentProducts
            self.paymentProducts.stringFormatter = self.stringFormatter
            self.assetManager.initializeImages(for: paymentProducts.paymentProducts)
            self.setLogoForPaymentItems(for: paymentProducts.paymentProducts){
                success(paymentProducts)
            }
        }, failure: failure)
    }
    
    public func paymentProductNetworks(forProductId paymentProductId: String, context: PaymentContext, success: @escaping (_ paymentProductNetworks: PaymentProductNetworks) -> Void, failure: @escaping (_ error: Error) -> Void) {
        communicator.paymentProductNetworks(forProduct: paymentProductId, context: context, success: { paymentProductNetworks in
            success(paymentProductNetworks)
        }, failure: { error in
            failure(error)
        })
    }
    
    public func paymentItems(for context: PaymentContext, groupPaymentProducts: Bool, success: @escaping (_ paymentItems: PaymentItems) -> Void, failure: @escaping (_ error: Error) -> Void) {
        communicator.paymentProducts(forContext: context, success: { paymentProducts in
            self.paymentProducts = paymentProducts
            self.paymentProducts.stringFormatter = self.stringFormatter
            self.assetManager.initializeImages(for: paymentProducts.paymentProducts)
            self.setLogoForPaymentItems(for: paymentProducts.paymentProducts){
                let items = PaymentItems(products: paymentProducts, groups: nil)
                success(items)
            }
        }, failure: failure)
    }
    
    public func paymentProduct(withId paymentProductId: String, context: PaymentContext, success: @escaping (_ paymentProduct: PaymentProduct) -> Void, failure: @escaping (_ error: Error) -> Void) {
        let key = "\(paymentProductId)-\(context.description)"
        
        if let paymentProduct = paymentProductMapping[key] as? PaymentProduct {
            success(paymentProduct)
        } else {
            communicator.paymentProduct(withIdentifier: paymentProductId, context: context, success: { paymentProduct in
                self.paymentProductMapping[key] = paymentProduct
                self.assetManager.initializeImages(for: paymentProduct)
                self.setLogoForDisplayHintsList(for: paymentProduct.displayHintsList){
                    success(paymentProduct)
                }
            }, failure: failure)
        }
    }
    
    public func iinDetails(forPartialCreditCardNumber partialCreditCardNumber: String,
                           context: PaymentContext?,
                           success: @escaping (_ iinDetailsResponse: IINDetailsResponse) -> Void,
                           failure: @escaping (_ error: Error) -> Void) {
        if partialCreditCardNumber.count < 6 {
            let response = IINDetailsResponse(status: .notEnoughDigits)
            success(response)
        } else if self.iinLookupPending == true {
            let response = IINDetailsResponse(status: .pending)
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
    
    public var clientSessionId: String {
        return communicator.clientSessionId
    }
    
    public func keyValuePairs(from dictionary: [String: String]) -> [[String: String]] {
        var keyValuePairs = [[String: String]]()
        for (key, value) in  dictionary {
            let pair = ["key": key, "value": value]
            keyValuePairs.append(pair)
        }
        return keyValuePairs
    }
    
    public func keyValueJSONFromDictionary(dictionary: [String: String]) -> String? {
        let keyValuePairs = self.keyValuePairs(from: dictionary)
        guard let JSONAsData = try? JSONSerialization.data(withJSONObject: keyValuePairs) else {
            Macros.DLog(message: "Unable to create JSON data from dictionary")
            return nil
        }
        
        return String(bytes: JSONAsData, encoding: String.Encoding.utf8)
    }
    
    
    private func setLogoForPaymentItems(for paymentItems: [BasicPaymentItem], completion: @escaping() -> Void){
        for paymentItem in paymentItems {
            setLogoForDisplayHintsList(for: paymentItem.displayHintsList, completion: {})
        }
        completion()
    }
    
    private func setLogoForDisplayHintsList(for displayHints: [PaymentItemDisplayHints], completion: @escaping() -> Void){
        for displayHint in displayHints {
            assetManager.getLogoByStringURL(from: displayHint.logoPath) { data, response, error in
                guard let imageData = data, error == nil else { return }
                displayHint.logoImage = UIImage(data: imageData)
            }
        }
        completion()
    }
}
