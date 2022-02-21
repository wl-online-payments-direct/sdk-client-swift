Pod::Spec.new do |s|

  s.name          = "OnlinePaymentsKit"
  s.version       = "2.0.0"
  s.summary       = "Online payments Swift SDK"
  s.description   = <<-DESC
                    This native iOS SDK facilitates handling payments in your apps
                    using the Online Payments platform.
                    DESC

  s.homepage      = "https://github.com/wl-online-payments-direct/sdk-client-swift"
  s.license       = { :type => "MIT", :file => "LICENSE.txt" }
  s.author        = "Worldline"
  s.platform      = :ios, "9.0"
  s.source        = { :git => "https://github.com/wl-online-payments-direct/sdk-client-swift.git", :tag => s.version }
  s.source_files  = "OnlinePaymentsKit/**/*.swift"
  s.resource      = "OnlinePaymentsKit/OnlinePaymentsKit.bundle"
  s.swift_version = "5"
  
  s.dependency 'Alamofire', '~> 4.8'
  s.dependency 'CryptoSwift', '0.12.0'
end
