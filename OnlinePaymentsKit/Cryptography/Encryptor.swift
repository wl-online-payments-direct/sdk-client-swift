//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2025 Global Collect Services. All rights reserved.
//

import Foundation
internal import CryptoSwift
import Security

internal class Encryptor {
    func generateRSAKeyPair(withPublicTag publicTag: String, privateTag: String) {
        let privateKeyAttr: [String: Any] = [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: privateTag
        ]

        let publicKeyAttr: [String: Any] = [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: publicTag
        ]

        let keyPairAttr: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
            kSecPrivateKeyAttrs as String: privateKeyAttr,
            kSecPublicKeyAttrs as String: publicKeyAttr
        ]

        var error: Unmanaged<CFError>?
        if let privateKey = SecKeyCreateRandomKey(keyPairAttr as CFDictionary, &error) {
            guard SecKeyCopyPublicKey(privateKey) != nil else {
                Logger.log("Error while generating the public key")
                return
            }
        } else if let err = error {
            Logger.log("Error while generating pair of RSA keys: \(err.takeRetainedValue() as Error)")
        }
    }

    func RSAKey(withTag tag: String) -> (SecKey?) {
        var keyRef: CFTypeRef?

        let queryAttr: NSDictionary = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: tag as CFString,
            kSecAttrType: kSecAttrKeyTypeRSA,
            kSecReturnRef: true
        ]

        let copyStatus = SecItemCopyMatching(queryAttr, &keyRef)
        if copyStatus != errSecSuccess {
            Logger.log("Error while retrieving key with tag \(tag): \(copyStatus)")
        }

        return keyRef as! (SecKey?) // swiftlint:disable:this force_cast
    }

    func deleteRSAKey(withTag tag: String) {
        let keyAttr: NSDictionary = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: tag,
            kSecAttrKeyType: kSecAttrKeyTypeRSA
        ]

        let deleteStatus = SecItemDelete(keyAttr)
        if deleteStatus != errSecSuccess {
            Logger.log("Error while deleting h=the key with tag \(tag): \(deleteStatus)")
        }
    }

    func encryptRSA(data: Data, publicKey: SecKey) throws -> Data {
        let buffer = convertDataToByteArray(data: data)
        return try Data(encryptRSA(plaintext: buffer, publicKey: publicKey))
    }

    func encryptRSA(plaintext: [UInt8], publicKey: SecKey) throws -> [UInt8] {
        let dataToEncrypt = Data(plaintext)
        
        let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA1

        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            Logger.log("Algorithm not supported for the provided public key.")
            throw EncryptDataError.algorithmNotSupported
        }
        
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(publicKey, algorithm, dataToEncrypt as CFData, &error) else {
            if let encryptionError = error?.takeRetainedValue() {
                Logger.log("Encryption failed: \(encryptionError)")
                throw EncryptorError.encryptionFailed(encryptionError as Error)
            } else {
                throw EncryptorError.encryptionFailed(NSError(domain: "UnknownEncryptionError", code: -1, userInfo: nil))
            }
        }
        
        return Array(encryptedData as Data)
    }

    func decryptRSA(data: Data, privateKey: SecKey) throws -> Data {
        let buffer = convertDataToByteArray(data: data)
        return try Data(decryptRSA(ciphertext: buffer, privateKey: privateKey))
    }
    
    func decryptRSA(ciphertext: [UInt8], privateKey: SecKey) throws -> [UInt8] {
        let dataToDecrypt = Data(ciphertext)
        
        let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA1

        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm) else {
            throw EncryptDataError.algorithmNotSupported
        }
        
        var error: Unmanaged<CFError>?
        guard let decryptedData = SecKeyCreateDecryptedData(privateKey, algorithm, dataToDecrypt as CFData, &error) else {
            if let decryptionError = error?.takeRetainedValue() {
                Logger.log("Decryption failed: \(decryptionError)")
                throw EncryptorError.decryptionFailed(decryptionError as Error)
            } else {
                throw EncryptorError.decryptionFailed(NSError(domain: "UnknownDecryptionError", code: -1, userInfo: nil))
            }
        }
        
        return Array(decryptedData as Data)
    }

    func storePublicKey(publicKey: Data, tag: String) {
        let keyAttr: NSDictionary = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: tag,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecValueData: publicKey as NSData
        ]
        let addStatus = SecItemAdd(keyAttr as CFDictionary, nil)
        if addStatus != errSecSuccess {
            Logger.log("Error while adding key: \(addStatus)")
        }
    }

    func stripPublicKey(data: Data) throws -> (Data) {
        let publicKey = convertDataToByteArray(data: data)
        let result = try stripPublicKey(publicKey: publicKey)

        return Data(result)
    }

    func stripPublicKey(publicKey: [UInt8]) throws -> ([UInt8]) {
        let rsaPrefixLength = 24
        let rsaPublicKeyPrefix: [UInt8] =
            [
                0x30, 0x82, 0x01, 0x22, 0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7,
                0x0D, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0F, 0x00
            ]

        for index in 0..<rsaPrefixLength where rsaPublicKeyPrefix[index] != publicKey[index] {
            Logger.log("The provided public key data has an unexpected format")
            throw EncryptDataError.badPublicKeyFormat
        }

        return Array(publicKey[rsaPrefixLength..<publicKey.count])
    }

    // swiftlint:disable identifier_name
    func encryptAES(data: Data, key: Data, IV: Data) throws -> (Data) {
        let plaintext = convertDataToByteArray(data: data)

        let result = try encryptAES(plaintext: plaintext, key: Array(key), IV: Array(IV))

        return Data(result)
    }

    private func encryptAES(plaintext: [UInt8], key: [UInt8], IV: [UInt8]) throws -> ([UInt8]) {
        do {
            let aes = try AES(key: key, blockMode: CBC(iv: IV), padding: .pkcs7)
            let ciphertext = try aes.encrypt(plaintext)
            return ciphertext
        } catch {
            throw EncryptorError.encryptionFailed(error)
        }
    }

    func decryptAES(data: Data, key: Data, IV: Data) throws -> (Data) {
        let ciphertext = convertDataToByteArray(data: data)

        let result = try decryptAES(ciphertext: ciphertext, key: Array(key), IV: Array(IV))

        return Data(result)
    }

    private func decryptAES(ciphertext: [UInt8], key: [UInt8], IV: [UInt8]) throws -> ([UInt8]) {
        do {
            let aes = try AES(key: key, blockMode: CBC(iv: IV), padding: .pkcs7)
            let plaintext = try aes.decrypt(ciphertext)
            return plaintext
        } catch {
            throw EncryptorError.decryptionFailed(error)
        }
    }
    // swiftlint:enable identifier_name

    func generateHMAC(data: Data, key: Data) throws -> (Data) {
        let input = convertDataToByteArray(data: data)
        let keyBytes = convertDataToByteArray(data: key)
        let hmac = try generateHMAC(input: input, key: keyBytes)

        return Data(hmac)
    }

    func generateHMAC(input: [UInt8], key: [UInt8]) throws -> ([UInt8]) {
        do {
            let hmac = try HMAC(key: key, variant: .sha2(.sha512)).authenticate(input)
            return hmac
        } catch {
            throw EncryptDataError.hmacGenerationFailed
        }
    }

    func generateRandomBytes(length: Int) -> (Data) {
        return Data(AES.randomIV(length))
    }

    func generateUUID() -> (String) {
        return UUID().uuidString
    }

    private func convertDataToByteArray(data: Data) -> ([UInt8]) {
        var buffer = [UInt8](repeating: 0x0, count: data.count)
        data.copyBytes(to: &buffer, count: data.count * MemoryLayout<UInt8>.size)

        return buffer
    }
}
