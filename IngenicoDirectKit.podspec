Pod::Spec.new do |s|

  s.name          = "IngenicoDirectKit"
  s.version       = "1.0.2"
  s.summary       = "Ingenico Direct Swift SDK"
  s.description   = <<-DESC
                    This native iOS SDK facilitates handling payments in your apps
                    using the Ingenico ePayments platform of Ingenico ePayments.
                    DESC

  s.homepage      = "https://github.com/Ingenico/direct-sdk-client-swift"
  s.license       = { :type => "MIT", :file => "LICENSE.txt" }
  s.author        = "Ingenico"
  s.platform      = :ios, "9.0"
  s.source        = { :git => "https://github.com/Ingenico/direct-sdk-client-swift.git", :tag => s.version }
  s.source_files  = "IngenicoDirectKit/**/*.swift"
  s.resource      = "IngenicoDirectKit/IngenicoDirectKit.bundle"
  s.swift_version = "5"
  
  s.dependency 'Alamofire', '~> 4.8'
  s.dependency 'CryptoSwift', '0.12.0'
end
