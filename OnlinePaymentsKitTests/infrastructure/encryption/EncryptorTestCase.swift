/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import XCTest
@testable import OnlinePaymentsKit

class EncryptorTestCase: XCTestCase {
    var encryptor: Encryptor!
    let publicTag = "test-public-tag"
    let privateTag = "test-private-tag"

    override func setUp() {
        super.setUp()
        encryptor = Encryptor()
        
        // Clean up any existing keys
        encryptor.deleteRSAKey(withTag: publicTag)
        encryptor.deleteRSAKey(withTag: privateTag)
    }
    
    override func tearDown() {
        // Clean up keys after tests
        encryptor.deleteRSAKey(withTag: publicTag)
        encryptor.deleteRSAKey(withTag: privateTag)
        encryptor = nil
        super.tearDown()
    }

    func testGenerateRandomByteWithLength() {
        var dataCollection = [Data]()
        for _ in 0..<10 {
            dataCollection.append(encryptor.generateRandomBytes(length: 16))
        }

        for outerIndex in 0..<10 {
            for innerIndex in outerIndex+1..<10 {
                let data1 = dataCollection[outerIndex]
                let data2 = dataCollection[innerIndex]

                XCTAssertNotEqual(data1, data2, "Generated the same random bytes more than once")
            }
        }
    }

    func testDeleteRSAKeyWithtag() {
        encryptor.generateRSAKeyPair(withPublicTag: publicTag, privateTag: privateTag)

        encryptor.deleteRSAKey(withTag: publicTag)
        encryptor.deleteRSAKey(withTag: privateTag)

        let queryAttributes: NSDictionary = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: publicTag,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecReturnRef: true
        ]

        var key: CFTypeRef?
        let error = SecItemCopyMatching(queryAttributes, &key)
        XCTAssertEqual(error, errSecItemNotFound, "Retrieved a key that should be deleted already")
    }

    func testEncryptAES() {
        let AESKey = encryptor.generateRandomBytes(length: 32)
        let AESIV = encryptor.generateRandomBytes(length: 16)
        let input = Data([0, 255, 43, 1])

        do {
            let output = try encryptor.encryptAES(data: input, key: AESKey, IV: AESIV)
            XCTAssertEqual(
                output.count,
                16,
                "AES ciphertext does not have the right length: \(output.count)"
            )
            XCTAssertNotEqual(input, output, "AES does not perform encryption")
        } catch {
            if let encryptionError = error as? EncryptionError {
                XCTFail("Test testEncryptAES failed: \(encryptionError.message)")
            } else {
                XCTFail("Test testEncryptAES failed with unexpected error: \(error.localizedDescription)")
            }
        }
    }

    func testEncryptDecryptAES() {
        let AESKey = encryptor.generateRandomBytes(length: 32)
        let AESIV = encryptor.generateRandomBytes(length: 16)
        let input = Data([0, 255, 43, 1])
        
        do {
            let encrypted = try encryptor.encryptAES(data: input, key: AESKey, IV: AESIV)
            let decrypted = try encryptor.decryptAES(data: encrypted, key: AESKey, IV: AESIV)
            XCTAssertEqual(input, decrypted, "AES decryption fails to recover the original data")
        } catch {
            if let encryptionError = error as? EncryptionError {
                XCTFail("Test testEncryptDecryptAES failed: \(encryptionError.message)")
            } else {
                XCTFail("Test testEncryptDecryptAES failed with unexpected error: \(error.localizedDescription)")
            }
        }
    }

    func testGenerateHMACContent() {
        let hmacKey = encryptor.generateRandomBytes(length: 16)
        let input = Data([0, 255, 43, 1])
        
        do {
            let hmac1 = try encryptor.generateHMAC(data: input, key: hmacKey)
            let hmac2 = try encryptor.generateHMAC(data: input, key: hmacKey)
            XCTAssertEqual(hmac1, hmac2, "HMACs generated from the same input do not match")
        } catch {
            if let encryptionError = error as? EncryptionError {
                XCTFail("Failed to generate HMAC: \(encryptionError.message)")
            } else {
                XCTFail("Failed to generate HMAC with unexpected error: \(error.localizedDescription)")
            }
        }
    }

    func testgenerateUUID() {
        var UUIDCollection = [String]()
        let amount = 100

        for _ in 0..<amount {
            UUIDCollection.append(encryptor.generateUUID())
        }

        for outerIndex in 0..<amount {
            for innerIndex in outerIndex+1..<amount {
                XCTAssertNotEqual(
                    UUIDCollection[outerIndex],
                    UUIDCollection[innerIndex],
                    "Generated the same UUID more than once"
                )
            }
        }
    }
}
