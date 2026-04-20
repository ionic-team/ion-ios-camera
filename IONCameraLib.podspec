require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |spec|
  spec.name         = package['name']
  spec.version      = package['version']
  spec.summary      = package['description']

  spec.homepage     = package['repository']['url']
  spec.license      = { :type => package['license'], :file => "LICENSE" }
  spec.author       = { package['author'] => package['email'] }

  spec.ios.deployment_target = "14.0"

  spec.source       = { :git => package['repository']['url'], :tag => "#{spec.version}" }
  spec.source_files  = "Sources/IONCameraLib/**/*.swift"
  spec.resource_bundles = {
  'IONCameraLibResources' => [
    'Sources/IONCameraLib/Interfaces/Editor/CameraLocal.xcassets'
  ]
}

  spec.frameworks = "AVFoundation", "AVKit", "UIKit"

  # SwiftUICore is a sub-framework split from SwiftUI in iOS 17. Building with
  # the iOS 17+ SDK creates a hard link to it, which crashes on iOS 15/16 where
  # it doesn't exist. Weak-linking makes it optional at load time.
  spec.user_target_xcconfig = { 'OTHER_LDFLAGS' => '-weak_framework SwiftUICore' }

  spec.swift_versions = ['5.7', '5.8', '5.9', '5.10', '5.11']
end
