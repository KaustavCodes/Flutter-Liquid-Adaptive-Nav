#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint liquid_adaptive_nav.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'liquid_adaptive_nav'
  s.version          = '0.0.2'
  s.summary          = 'Adaptive liquid-glass navigation bar, Duo side-strip dock, and macOS/desktop sidebar.'
  s.description      = <<-DESC
A Flutter plugin providing adaptive Apple Liquid Glass pill navigation capsules, foldable & iPhone Duo vertical side-strip docking, and a collapsible macOS/desktop sidebar with Light/Dark theming.
                       DESC
  s.homepage         = 'https://kauscoder.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Kaustav Halder' => 'contact@kauscoder.com' }

  s.source           = { :path => '.' }
  s.source_files = 'liquid_adaptive_nav/Sources/liquid_adaptive_nav/**/*'
  s.resource_bundles = {
    'liquid_adaptive_nav_privacy' => ['liquid_adaptive_nav/Sources/liquid_adaptive_nav/PrivacyInfo.xcprivacy']
  }

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.15'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
