Pod::Spec.new do |spec|

  spec.name         = "startio-admob-mediation"
  spec.version      = "3.0.2"
  spec.summary      = "Start.io <-> AdMob iOS Mediation Adapter."

  spec.description  = <<-DESC
  Using this adapter you will be able to integrate Start.io SDK via AdMob mediation
                   DESC

  spec.homepage     = "https://www.start.io"
  spec.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  spec.author       = { "iOS Dev" => "iosdev@startapp.com" }
  
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => "https://github.com/StartApp-SDK/ios-admob-mediation.git", :tag => spec.version.to_s }
  spec.source_files  = "StartioAdmobMediation/**/*.{h,m}"
  # spec.public_header_files = "StartioAdmobMediation/**/*.h"

  spec.frameworks = "Foundation", "UIKit"

  spec.requires_arc = true
  spec.static_framework = true
  
  spec.dependency "Google-Mobile-Ads-SDK", "~> 12.14"
  spec.dependency "StartAppSDK", "~> 4.13"

end
