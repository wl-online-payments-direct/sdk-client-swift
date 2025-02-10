//
// Do not remove or alter the notices in this preamble.
// This software code is created for Ingencio ePayments on 27.1.25.
// Copyright © 2025 Global Collect Services. All rights reserved.
// 

internal class Logger {
    public static func log(_ message: String) {
        Macros.DLog(message: message)
    }
}
