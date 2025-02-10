//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation

internal class JOSEEncryptor {
    private let AESKeyLength = 32
    private let IVLength = 16
    private let HMACLength = 32

    var encryptor = Encryptor()

    convenience init(encryptor: Encryptor) {
        self.init()

        self.encryptor = encryptor
    }

    func generateProtectedHeader(withKey keyId: String) -> String {
        return "{\"alg\":\"RSA-OAEP\", \"enc\":\"A256CBC-HS512\", \"kid\":\"\(keyId)\"}"
    }

    func encryptToCompactSerialization(
        JSON: String,
        withPublicKey publicKey: SecKey,
        keyId: String
    ) throws -> String {
        let protectedheader = generateProtectedHeader(withKey: keyId).data(using: String.Encoding.utf8)

        let AESKey = encryptor.generateRandomBytes(length: AESKeyLength)
        let HMACKey = encryptor.generateRandomBytes(length: HMACLength)

        let encodedProtectedHeader = protectedheader!.base64URLEncode()

        var key = Data([UInt8](HMACKey))
        key.append([UInt8](AESKey), count: AESKey.count)
        let encryptedKey = try encryptor.encryptRSA(data: key, publicKey: publicKey)
        let encodedKey = encryptedKey.base64URLEncode()

        let initializationVector = encryptor.generateRandomBytes(length: IVLength)

        let encodedIV = initializationVector.base64URLEncode()

        let additionalAuthenticatedData = encodedProtectedHeader.data(using: String.Encoding.ascii)!

        // swiftlint:disable identifier_name
        let AL = computeAL(forData: additionalAuthenticatedData)
        // swiftlint:enable identifier_name

        let ciphertext =
                try encryptor.encryptAES(
                    data: JSON.data(using: String.Encoding.utf8)!,
                    key: AESKey,
                    IV: initializationVector
                )

        let encodedCiphertext = ciphertext.base64URLEncode()

        var authenticationData = Data()
        authenticationData.append(additionalAuthenticatedData)
        authenticationData.append(initializationVector)
        authenticationData.append(ciphertext)
        authenticationData.append(AL)

        let authenticationTag = try encryptor.generateHMAC(data: authenticationData, key: HMACKey)

        let truncatedAuthenticationTag = authenticationTag.subdata(in: 0..<HMACLength)
        let encodedAuthenticationTag = truncatedAuthenticationTag.base64URLEncode()

        let components = [encodedProtectedHeader, encodedKey, encodedIV, encodedCiphertext, encodedAuthenticationTag]

        return components.joined(separator: ".")
    }

    // periphery:ignore
    func decryptFromCompactSerialization(JOSE: String, withPrivateKey privateKey: SecKey) throws -> String {
        let components = JOSE.components(separatedBy: ".")
        let decodedProtectedHeader = String(data: components[0].base64URLDecode(),
                                            encoding: String.Encoding.utf8)

        let encryptedKeys = components[1].base64URLDecode()
        let decryptedKeys = try encryptor.decryptRSA(data: encryptedKeys, privateKey: privateKey)
        let HMACKey = decryptedKeys.subdata(in: 0..<HMACLength)
        let AESKey = decryptedKeys.subdata(in: 0..<AESKeyLength)

        let initializationVector = components[2].base64URLDecode()

        let ciphertext = components[3].base64URLDecode()
        let plaintext = try encryptor.decryptAES(data: ciphertext, key: AESKey, IV: initializationVector)

        _ = String(data: plaintext, encoding: String.Encoding.utf8)

        let additionalAuthenticatedData = components[0].data(using: String.Encoding.ascii)!

        // swiftlint:disable identifier_name
        let AL = computeAL(forData: additionalAuthenticatedData)
        // swiftlint:enable identifier_name

        var authenticationData = Data()
        authenticationData.append(additionalAuthenticatedData)
        authenticationData.append(initializationVector)
        authenticationData.append(ciphertext)
        authenticationData.append(AL)
        let authenticationTag = try encryptor.generateHMAC(data: authenticationData, key: HMACKey)

        let truncatedAuthenticationTag = authenticationTag.subdata(in: 0..<HMACLength)
        let encodedAuthenticationTag = truncatedAuthenticationTag.base64URLEncode()

        var decrypted = "\(String(describing: decodedProtectedHeader))\n\(JOSE)\n"

        if encodedAuthenticationTag == components[4] {
            decrypted += "Authentication was successful"
        } else {
            decrypted += "Authentication failed"
        }

        return decrypted
    }

    func computeAL(forData data: Data) -> Data {
        var lengthInBits = data.count * 8
        // swiftlint:disable identifier_name
        var AL = Data(bytes: &lengthInBits, count: MemoryLayout<Int>.size)
        AL.reverse()

        return AL
        // swiftlint:enable identifier_name
    }
}
