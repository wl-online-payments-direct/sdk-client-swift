//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import XCTest
@testable import OnlinePaymentsKit

class EncryptorTestCase: XCTestCase {
    var encryptor = Encryptor()
    let publicTag = "test-public-tag"
    let privateTag = "test-private-tag"

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGenerateRandomByteWithLength() {
        var dataCollection = [Data?]()
        for _ in 0..<10 {
            dataCollection.append(encryptor.generateRandomBytes(length: 16))
        }

        for outerIndex in 0..<10 {
            for innerIndex in outerIndex+1..<10 {
                let data1 = dataCollection[outerIndex]
                let data2 = dataCollection[innerIndex]

                if data1 == data2 {
                    XCTFail("Generated the same random bytes more than once")
                }
            }
        }
    }

    func testDeleteRSAKeyWithtag() {
        encryptor.deleteRSAKey(withTag: publicTag)
        encryptor.deleteRSAKey(withTag: privateTag)

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
        let output = encryptor.encryptAES(data: input, key: AESKey!, IV: AESIV!)
        XCTAssertEqual(
            output?.count,
            16,
            "AES ciphertext does not have the right length: \(String(describing: output?.count))"
        )
        XCTAssertNotEqual(input, output, "AES does not perform encryption")
    }

    func testEncryptDecryptAES() {
        let AESKey = encryptor.generateRandomBytes(length: 32)
        let AESIV = encryptor.generateRandomBytes(length: 16)
        let input = Data([0, 255, 43, 1])
        let encrypted = encryptor.encryptAES(data: input, key: AESKey!, IV: AESIV!)
        let decrypted = encryptor.decryptAES(data: encrypted!, key: AESKey!, IV: AESIV!)
        XCTAssertEqual(input, decrypted, "AES decryption fails to recover the original data")
    }

    func testGenerateHMACContent() {
        let hmacKey = encryptor.generateRandomBytes(length: 16)
        let input = Data([0, 255, 43, 1])
        let hmac1 = encryptor.generateHMAC(data: input, key: hmacKey!)
        let hmac2 = encryptor.generateHMAC(data: input, key: hmacKey!)
        XCTAssertEqual(hmac1, hmac2, "HMACs generated from the same input do not match")
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
