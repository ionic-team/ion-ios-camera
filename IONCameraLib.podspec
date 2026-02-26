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

  spec.swift_versions = ['5.7', '5.8', '5.9', '5.10', '5.11']
end
