//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import UIKit

@objc public class FileManager: NSObject {
    @objc public func dict(atPath path: String) -> NSDictionary? {
        return NSDictionary(contentsOfFile: path)
    }

    @objc public func image(atPath path: String) -> UIImage? {
        return UIImage(contentsOfFile: path)
    }

    @objc public func data(atURL url: URL) throws -> Data {
        return try Data(contentsOf: url)
    }

    @objc public func write(toURL url: URL, data: Data, options: Data.WritingOptions) throws {
        try data.write(to: url, options: options)
    }
}
