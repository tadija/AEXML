Pod::Spec.new do |s|
s.name = 'AEXML'
s.version = '1.3.1'
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.summary = 'Simple and lightweight XML parser for iOS written in Swift'

s.homepage = 'https://github.com/tadija/AEXML'
s.author = { 'tadija' => 'tadija@me.com' }
s.social_media_url = 'http://twitter.com/tadija'

s.source = { :git => 'https://github.com/tadija/AEXML.git', :tag => s.version }
s.source_files = 'AEXML/*.swift'
s.ios.deployment_target = '8.0'
end