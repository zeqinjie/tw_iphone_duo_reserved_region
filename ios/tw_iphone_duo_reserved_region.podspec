Pod::Spec.new do |s|
  s.name             = 'tw_iphone_duo_reserved_region'
  s.version          = '1.0.0'
  s.summary          = 'Provides active iPhone Duo reserved regions to Flutter.'
  s.description      = <<-DESC
Queries active iPhone Duo occlusion regions and exposes them to Flutter layouts.
                       DESC
  s.homepage         = 'https://github.com/zeqinjie/tw_iphone_duo_reserved_region'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'zhengzeqin' => 'zeqinjie@qq.com' }
  s.source           = { :path => '.' }
  s.source_files =
    'tw_iphone_duo_reserved_region/Sources/tw_iphone_duo_reserved_region/**/*.{h,m}'
  s.public_header_files =
    'tw_iphone_duo_reserved_region/Sources/tw_iphone_duo_reserved_region/include/**/*.h'
  s.dependency 'Flutter'
  s.platform         = :ios, '15.5'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
