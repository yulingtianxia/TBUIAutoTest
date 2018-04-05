Pod::Spec.new do |s|
s.name         = "TBUIAutoTest"
s.version      = "1.1.4"
s.summary      = "Generating accessibilityIdentifier for UIAutomation."
s.description  = <<-DESC
TBUIAutoTest generates UIAutomation `accessibilityIdentifier` for you.
DESC
s.homepage     = "https://github.com/yulingtianxia/TBUIAutoTest"

s.license = { :type => 'MIT', :file => 'LICENSE' }
s.author       = { "YangXiaoyu" => "yulingtianxia@gmail.com" }
s.social_media_url = 'https://twitter.com/yulingtianxia'
s.source       = { :git => "https://github.com/yulingtianxia/TBUIAutoTest.git", :tag => s.version.to_s }

s.platform     = :ios, '7.0'
s.requires_arc = true

s.source_files = "TBUIAutoTest/*.{h,m}"
s.public_header_files = "TBUIAutoTest/TBUIAutoTest.h"
s.frameworks = 'Foundation', 'UIKit'

end
