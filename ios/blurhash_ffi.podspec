#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint blurhash_ffi.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'blurhash_ffi'
  s.version          = '0.0.3'
  s.summary          = 'A new Flutter FFI plugin project.'
  s.description      = <<-DESC
A new Flutter FFI plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes**/*.h'
  s.resource_bundles = {'blurhash_ffi_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  s.ios.deployment_target = '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'ENABLE_BITCODE' => 'NO',
  }
  # s.xcconfig = { 
  #   'OTHER_LDFLAGS' => '-framework blurhash_ffi',
  # }
  s.swift_version = '5.0'
  s.static_framework = true
  # s.preserve_paths = 'Frameworks/blurhash_ffi.xcframework'
  s.ios.vendored_libraries = 'Libraries/ios/*.a'
  # s.vendored_frameworks = 'Frameworks/blurhash_ffi.xcframework'
end
