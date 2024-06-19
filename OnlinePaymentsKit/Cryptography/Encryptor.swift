//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation
import CryptoSwift
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

        var publicKey, privateKey: SecKey?

        let genStatus = SecKeyGeneratePair(keyPairAttr as CFDictionary, &publicKey, &privateKey)

        if genStatus != errSecSuccess {
            Macros.DLog(message: "Error while generating pair of RSA keys: \(genStatus)")
            // We cannot call SecCopyErrorMessageString on iOS
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
            Macros.DLog(message: "Error while retrieving key with tag \(tag): \(copyStatus)")
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
            Macros.DLog(message: "Error while deleting h=the key with tag \(tag): \(deleteStatus)")
        }
    }

    func encryptRSA(data: Data, publicKey: SecKey) -> Data {
        let buffer = convertDataToByteArray(data: data)
        return Data(encryptRSA(plaintext: buffer, publicKey: publicKey))
    }

    func encryptRSA(plaintext: [UInt8], publicKey: SecKey) -> [UInt8] {

        var cipherBufferSize = SecKeyGetBlockSize(publicKey)
        var cipherBuffer = [UInt8](repeating: 0, count: cipherBufferSize)

        SecKeyEncrypt(publicKey,
                      SecPadding.OAEP,
                      plaintext,
                      plaintext.count,
                      &cipherBuffer,
                      &cipherBufferSize)

        return cipherBuffer
    }

    func decryptRSA(data: Data, privateKey: SecKey) -> Data {
        let buffer = convertDataToByteArray(data: data)
        return Data(decryptRSA(ciphertext: buffer, privateKey: privateKey))
    }

    func decryptRSA(ciphertext: [UInt8], privateKey: SecKey) -> [UInt8] {

        var plainBufferSize = SecKeyGetBlockSize(privateKey)
        var plainBuffer = [UInt8](repeating: 0, count: plainBufferSize)

        SecKeyDecrypt(privateKey,
                      SecPadding.OAEP,
                      ciphertext,
                      ciphertext.count,
                      &plainBuffer,
                      &plainBufferSize)

        return plainBuffer
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
            Macros.DLog(message: "Error while adding key: \(addStatus)")
        }
    }

    func stripPublicKey(data: Data) -> (Data?) {
        let publicKey = convertDataToByteArray(data: data)
        if let result = stripPublicKey(publicKey: publicKey) {
            return Data(result)
        } else {
            return nil
        }
    }

    func stripPublicKey(publicKey: [UInt8]) -> ([UInt8]?) {
        let prefixLength = 24
        let prefix: [UInt8] =
            [
                0x30, 0x82, 0x01, 0x22, 0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7,
                0x0D, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0F, 0x00
            ]

        for index in 0..<prefixLength where prefix[index] != publicKey[index] {
            Macros.DLog(message: "The provided data has an unexpected format")
            return nil
        }

        return Array(publicKey[prefixLength..<publicKey.count])
    }

    // swiftlint:disable identifier_name
    func encryptAES(data: Data, key: Data, IV: Data) -> (Data?) {
        let plaintext = convertDataToByteArray(data: data)

        if let result = encryptAES(plaintext: plaintext, key: key.bytes, IV: IV.bytes) {
            return Data(result)
        }
        return nil
    }

    private func encryptAES(plaintext: [UInt8], key: [UInt8], IV: [UInt8]) -> ([UInt8]?) {
        guard let aes = try? AES(key: key, blockMode: CBC(iv: IV), padding: .pkcs7),
            let ciphertext = try? aes.encrypt(plaintext) else {
            return nil
        }

        return ciphertext
    }

    func decryptAES(data: Data, key: Data, IV: Data) -> (Data?) {
        let ciphertext = convertDataToByteArray(data: data)

        if let result = decryptAES(ciphertext: ciphertext, key: key.bytes, IV: IV.bytes) {
            return Data(result)
        }
        return nil
    }

    private func decryptAES(ciphertext: [UInt8], key: [UInt8], IV: [UInt8]) -> ([UInt8]?) {
        guard let aes = try? AES(key: key, blockMode: CBC(iv: IV), padding: .pkcs7),
            let plaintext = try? aes.decrypt(ciphertext) else {
            return nil
        }

        return plaintext
    }
    // swiftlint:enable identifier_name

    func generateHMAC(data: Data, key: Data) -> (Data?) {
        let input = convertDataToByteArray(data: data)
        let keyBytes = convertDataToByteArray(data: key)
        if let hmac = generateHMAC(input: input, key: keyBytes) {
            return Data(hmac)
        } else {
            return nil
        }
    }

    func generateHMAC(input: [UInt8], key: [UInt8]) -> ([UInt8]?) {
        guard let hmac = try? HMAC(key: key, variant: .sha512).authenticate(input) else {
            return nil
        }

        return hmac
    }

    func generateRandomBytes(length: Int) -> (Data?) {
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
