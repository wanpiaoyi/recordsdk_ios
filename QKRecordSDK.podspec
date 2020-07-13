#
# Be sure to run `pod lib lint QKRecordSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QKRecordSDK'
  s.version          = '1.0.0'
  s.summary          = 'A short description of QKRecordSDK.'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/qklive/recordsdk_ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'quklive' => 'yangpeng@quklive.com' }
  s.source           = { :git => 'https://github.com/qklive/recordsdk_ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  
   s.resource_bundles = {
     'QKRecordSDK' => ['QKRecordSDK/Assets/img/*','QKRecordSDK/Assets/xib/*']
   }
  s.static_framework      = true

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.xcconfig = {"OTHER_LDFLAGS" => "-ObjC"}   
  s.dependency 'QKPubBean'
  s.default_subspec = 'clipSdkDemo'
  # use the built-in library version of sqlite3
  s.source_files = 'QKRecordSDK/Classes/newClip/imgSelect/LocalOrSystemVideos.h','QKRecordSDK/Classes/newClip/viewController/ClipPubThings.h','QKRecordSDK/Classes/newClip/bean/QKMoviePartDrafts.h','QKRecordSDK/Classes/newClip/viewController/QKClipController.h'

  s.subspec 'clipSdkDemo' do |ss|
    ss.source_files = 'QKRecordSDK/Classes/**/*/*.{h,m}'
  end

  #pod lib lint --use-libraries --allow-warnings --verbose --skip-import-validation --skip-tests
  #pod trunk push QKRecordSDK.podspec --skip-import-validation --use-libraries --allow-warnings  --verbose
end
