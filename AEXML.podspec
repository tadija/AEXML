Pod::Spec.new do |s|

s.name = 'AEXML'
s.version = '4.7.2'
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.summary = 'Swift minion for simple and lightweight XML parsing'

s.source = { :git => 'https://github.com/tadija/AEXML.git', :tag => s.version }
s.source_files = 'Sources/AEXML/*.swift'

s.swift_versions = ['4.0', '4.2', '5.0', '5.1', '5.2', '5.3', '5.9']

s.ios.deployment_target = '17.0'
s.osx.deployment_target = '14.0'
s.tvos.deployment_target = '17.0'
s.watchos.deployment_target = '10.0'

s.homepage = 'https://github.com/tadija/AEXML'
s.author = { 'tadija' => 'tadija@me.com' }
s.social_media_url = 'https://x.com/tadija'

end
