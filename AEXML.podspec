Pod::Spec.new do |s|

s.name = 'AEXML'
s.summary = 'Swift minion for simple and lightweight XML parsing'
s.version = '4.4.0'
s.license = { :type => 'MIT', :file => 'LICENSE' }

s.source = { :git => 'https://github.com/tadija/AEXML.git', :tag => s.version }
s.source_files = 'Sources/AEXML/*.swift'

s.swift_version = '5.0'

s.ios.deployment_target = '8.0'
s.osx.deployment_target = '10.10'
s.tvos.deployment_target = '9.0'
s.watchos.deployment_target = '3.0'

s.homepage = 'https://github.com/tadija/AEXML'
s.author = { 'tadija' => 'tadija@me.com' }
s.social_media_url = 'http://twitter.com/tadija'

end
