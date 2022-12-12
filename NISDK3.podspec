#
# Be sure to run `pod lib lint NISDK3.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NISDK3'
  s.version          = '1.0.6'
  s.summary          = 'iOS SDK for NeoSmartPen'

  s.description      = 'NeoSmartpen Controller with Bluetooth'

  s.homepage         = 'https://www.neosmartpen.com'
  s.license          = { :type => 'GPL-3.0', :file => 'LICENSE' }
  s.author           = { 'NeoLAB Convergence Inc.' => 'https://github.com/NeoSmartpen/iOS-SDK3.0' }
  s.source           = { :git => 'https://github.com/NeoSmartpen/iOS-SDK3.0.git', :tag => s.version.to_s }
  
  s.swift_version = '5.0'
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = "10.13"
  
  s.source_files = 'NISDK3/Classes/**/*'
  
  # s.resource_bundles = {
  #   'NISDK3' => ['NISDK3/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
