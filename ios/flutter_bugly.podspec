#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_bugly'
  s.version          = '0.3.2+1'
  s.summary          = 'Flutter plugin for Tencent Bugly.'
  s.description      = <<-DESC
Flutter plugin for Tencent Bugly, Crash monitoring, Crash analysis, exception reporting, application update, data statistics, etc.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Bugly'
  s.static_framework = true

  s.ios.deployment_target = '8.0'
end

