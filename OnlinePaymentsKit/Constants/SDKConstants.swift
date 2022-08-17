//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 16/07/2020
// Copyright © 2020 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

@objc(OPSDKConstants)
public class SDKConstants: NSObject {

    @objc(kOPSDKLocalizable)
    public static let kSDKLocalizable = "OPSDKLocalizable"
    @objc(kOPImageMapping)
    public static let kImageMapping = "kImageMapping"
    @objc(kOPImageMappingInitialized)
    public static let kImageMappingInitialized = "kImageMappingInitialized"
    @objc(kOPIINMapping)
    public static let kIINMapping = "kIINMapping"

    @objc(kOPApplePayIdentifier)
    public static let kApplePayIdentifier = "302"
    @objc(kOPGooglePayIdentifier)
    public static let kGooglePayIdentifier = "320"

    @objc(kOPAPIVersion)
    public static let kApiVersion = "client/v1"

    #if SWIFT_PACKAGE
    @objc(kOPSDKBundlePath)
    public static var kSDKBundlePath = Bundle.module.path(forResource: "OnlinePaymentsKit", ofType: "bundle")
    #elseif COCOAPODS
    @objc(kOPSDKBundleIdentifier)
    public static var kSDKBundleIdentifier = "org.cocoapods.OnlinePaymentsKit"
    @objc(kOPSDKBundlePath)
    public static var kSDKBundlePath = Bundle(identifier: SDKConstants.kSDKBundleIdentifier)?.path(forResource: "OnlinePaymentsKit", ofType: "bundle")
    #else
    @objc(kOPSDKBundleIdentifier)
    public static var kSDKBundleIdentifier = "com.onlinepayments.OnlinePaymentsKit"
    @objc(kOPSDKBundlePath)
    public static var kSDKBundlePath = Bundle(identifier: SDKConstants.kSDKBundleIdentifier)?.path(forResource: "OnlinePaymentsKit", ofType: "bundle")
    #endif

    @objc(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO:)
    public static func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: String) -> Bool {
        return UIDevice.current.systemVersion.compare(v, options: String.CompareOptions.numeric) != .orderedAscending
    }
    
    @objc(StandardUserDefaults)
    public static let StandardUserDefaults = UserDefaults.standard
    
    @objc(DocumentsFolderPath)
    public static let DocumentsFolderPath = (NSHomeDirectory() as NSString).appendingPathComponent("Documents")
    
    @objc(kOPCountryCodes)
    public static let kCountryCodes = "AF, AX, AL, DZ, AS, AD, AO, AI, AQ, AG, AR, AM, AW, AU, AT, AZ, BS, BH, BD, BB, BY, BE, BZ, BJ, BM, BT, BO, BQ, BA, BW, BV, BR, IO, BN, BG, BF, BI, KH, CM, CA, CV, KY, CF, TD, CL, CN, CX, CC, CO, KM, CG, CD, CK, CR, CI, HR, CU, CW, CY, CZ, DK, DJ, DM, DO, EC, EG, SV, GQ, ER, EE, ET, FK, FO, FJ, FI, FR, GF, PF, TF, GA, GM, GE, DE, GH, GI, GR, GL, GD, GP, GU, GT, GG, GN, GW, GY, HT, HM, VA, HN, HK, HU, IS, IN, ID, IR, IQ, IE, IM, IL, IT, JM, JP, JE, JO, KZ, KE, KI, KP, KR, KW, KG, LA, LV, LB, LS, LR, LY, LI, LT, LU, MO, MK, MG, MW, MY, MV, ML, MT, MH, MQ, MR, MU, YT, MX, FM, MD, MC, MN, ME, MS, MA, MZ, MM, NA, NR, NP, NL, AN, NC, NZ, NI, NE, NG, NU, NF, MP, NO, OM, PK, PW, PS, PA, PG, PY, PE, PH, PN, PL, PT, PR, QA, RE, RO, RU, RW, BL, SH, KN, LC, MF, PM, VC, WS, SM, ST, SA, SN, RS, SC, SL, SG, SX, SK, SI, SB, SO, ZA, GS, ES, LK, SD, SR, SJ, SZ, SE, CH, SY, TW, TJ, TZ, TH, TL, TG, TK, TO, TT, TN, TR, TM, TC, TV, UG, UA, AE, US, UM, UY, UZ, VU, VE, GB, VN, VG, VI, WF, EH, YE, ZM, ZW"
    
    @objc(kOPCurrencyCodes)
    public static let kCurrencyCodes = "AED, AFN, ALL, AMD, ANG, AOA, ARS, AUD, AWG, AZN, BAM, BBD, BDT, BGN, BHD, BIF, BMD, BND, BOB, BRL, BSD, BTN, BWP, BYN, BYR, BZD, CAD, CDF, CHF, CLP, CNY, COP, CRC, CUP, CVE, CZK, DJF, DKK, DOP, DZD, EGP, ERN, ETB, EUR, FJD, FKP, GBP, GEL, GHS, GIP, GMD, GNF, GTQ, GYD, HKD, HNL, HRK, HTG, HUF, IDR, ILS, INR, IQD, IRR, ISK, JMD, JOD, JPY, KES, KGS, KHR, KMF, KPW, KRW, KWD, KYD, KZT, LAK, LBP, LKR, LRD, LSL, LVL, LYD, MAD, MDL, MGA, MKD, MMK, MNT, MOP, MRO, MUR, MVR, MWK, MXN, MYR, MZN, NAD, NGN, NIO, NOK, NPR, NZD, OMR, PAB, PEN, PGK, PHP, PKR, PLN, PYG, QAR, RON, RSD, RUB, RWF, SAR, SBD, SCR, SDG, SEK, SGD, SHP, SLL, SOS, SRD, SSP, STD, SYP, SZL, THB, TJS, TND, TOP, TRY, TTD, TWD, TZS, UAH, UGX, USD, UYU, UZS, VEF, VND, VUV, WST, XAF, XCD, XOF, XPF, YER, ZAR, ZMK, ZWL"

}
