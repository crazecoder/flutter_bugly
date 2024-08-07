#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_bugly'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter bugly plugin.'
  s.description      = <<-DESC
A new Flutter bugly plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Bugly', '2.6.1'
  s.static_framework = true
  # s.pods_target_xcconfig = {'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulators*]' => 'x86_64'}

  s.ios.deployment_target = '8.0'
end

