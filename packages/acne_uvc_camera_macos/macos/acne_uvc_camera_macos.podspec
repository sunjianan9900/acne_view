Pod::Spec.new do |s|
  s.name             = 'acne_uvc_camera_macos'
  s.version          = '0.0.1'
  s.summary          = 'macOS external UVC camera support'
  s.description      = 'Flutter plugin for external UVC cameras on macOS'
  s.homepage         = 'https://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { '痘迹' => 'dev@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.15'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
