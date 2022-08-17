//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc(OPJOSEEncryptor)
public class JOSEEncryptor: NSObject {
    @objc public var encryptor = Encryptor()

    @objc public convenience init(encryptor: Encryptor) {
        self.init()

        self.encryptor = encryptor
    }

    @objc public func generateProtectedHeader(withKey keyId: String) -> String {
        let header = "{\"alg\":\"RSA-OAEP\", \"enc\":\"A256CBC-HS512\", \"kid\":\"\(keyId)\"}"
        return header
    }

    @objc public func encryptToCompactSerialization(JSON: String, withPublicKey publicKey: SecKey, keyId: String) -> String {
        guard let protectedheader = generateProtectedHeader(withKey: keyId).data(using: String.Encoding.utf8),
            let AESKey = encryptor.generateRandomBytes(length: 32),
            let HMACKey = encryptor.generateRandomBytes(length: 32)
            else {
                return ""
        }
        let encodedProtectedHeader = protectedheader.base64URLEncode()

        var key = Data([UInt8](HMACKey))
        key.append([UInt8](AESKey), count: AESKey.count)
        let encryptedKey = encryptor.encryptRSA(data: key, publicKey: publicKey)
        let encodedKey = encryptedKey.base64URLEncode()

        guard let IV = encryptor.generateRandomBytes(length: 16) else {
            return ""
        }
        let encodedIV = IV.base64URLEncode()

        guard let additionalAuthenticatedData = encodedProtectedHeader.data(using: String.Encoding.ascii) else {
            return ""
        }
        let AL = computeAL(forData: additionalAuthenticatedData)

        guard let ciphertext = encryptor.encryptAES(data: JSON.data(using: String.Encoding.utf8)!, key: AESKey, IV: IV) else {
            return ""
        }
        let encodedCiphertext = ciphertext.base64URLEncode()

        var authenticationData = additionalAuthenticatedData
        authenticationData.append(IV)
        authenticationData.append(ciphertext)
        authenticationData.append(AL)
        guard let authenticationTag = encryptor.generateHMAC(data: authenticationData, key: HMACKey) else {
            return ""
        }
        let truncatedAuthenticationTag = authenticationTag.subdata(in: 0..<32)
        let encodedAuthenticationTag = truncatedAuthenticationTag.base64URLEncode()

        let components = [encodedProtectedHeader, encodedKey, encodedIV, encodedCiphertext, encodedAuthenticationTag]
        let concatenatedComponents = components.joined(separator: ".")

        return concatenatedComponents
    }

    @objc public func decryptFromCompactSerialization(JOSE: String, withPrivateKey privateKey: SecKey) -> String {
        let components = JOSE.components(separatedBy: ".")
        let decodedProtectedHeader = String(data: components[0].base64URLDecode(),
                                            encoding: String.Encoding.utf8)

        let encryptedKeys = components[1].base64URLDecode()
        let decryptedKeys = encryptor.decryptRSA(data: encryptedKeys, privateKey: privateKey)
        let HMACKey = decryptedKeys.subdata(in: 0..<32)
        let AESKey = decryptedKeys.subdata(in: 0..<32)

        let IV = components[2].base64URLDecode()

        let ciphertext = components[3].base64URLDecode()
        guard let plaintext = encryptor.decryptAES(data: ciphertext, key: AESKey, IV: IV) else {
            return ""
        }
        _ = String(data: plaintext, encoding: String.Encoding.utf8)

        guard let additionalAuthenticatedData = components[0].data(using: String.Encoding.ascii) else {
            return ""
        }
        let AL = computeAL(forData: additionalAuthenticatedData)

        var authenticationData = additionalAuthenticatedData
        authenticationData.append(IV)
        authenticationData.append(ciphertext)
        authenticationData.append(AL)
        guard let authenticationTag = encryptor.generateHMAC(data: authenticationData, key: HMACKey) else {
            return ""
        }
        let truncatedAuthenticationTag = authenticationTag.subdata(in: 0..<32)
        let encodedAuthenticationTag = truncatedAuthenticationTag.base64URLEncode()

        var decrypted = "\(String(describing: decodedProtectedHeader))\n\(JOSE)\n"

        if encodedAuthenticationTag == components[4] {
            decrypted += "Authentication was successful"
        } else {
            decrypted += "Authentication failed"
        }

        return decrypted
    }

    @objc public func computeAL(forData data: Data) -> Data {
        var lengthInBits = data.count * 8
        var AL = Data(bytes: &lengthInBits, count: MemoryLayout<Int>.size)
        AL.reverse()
        return AL
    }
}
