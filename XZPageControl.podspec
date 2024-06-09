#
# Be sure to run `pod lib lint XZPageControl.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZPageControl'
  s.version          = '1.1.1'
  s.summary          = 'iOS分页控制组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                       组件 XZPageControl 支持自定义样式，方便快速开发出业务所需的指示器样式。
                       DESC

  s.homepage         = 'https://github.com/Xezun/XZPageControl'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'developer@xezun.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZPageControl.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
  
  s.subspec 'Code' do |ss|
    ss.dependency 'XZShapeView'
    ss.source_files = 'XZPageControl/Code/**/*.{h,m}'
    # ss.project_header_files = 'XZPageControl/Code/**/Private/*.{h,m}'
  end
  
  # s.resource_bundles = {
  #   'XZPageControl' => ['XZPageControl/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

