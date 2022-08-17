//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
// 

import Foundation

@objc public class Macros: NSObject {
    @objc public static func DLog(message: String, functionName: String = #function, fileName: String = #file) {
        #if DEBUG
        print("DLog: Original_Message = \(message)\n Method_Name = \(functionName)\n Line_Number = \(#line)")
        #else
        print("DLog: Original_Message = \(message)")
        #endif
    }
}
