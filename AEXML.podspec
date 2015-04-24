Pod::Spec.new do |s|
  s.name        = 'AEXML'
  s.version     = '1.0.0'
  s.summary     = 'Simple and lightweight XML parser for iOS written in Swift'
  s.homepage    = 'https://github.com/tadija/AEXML'
  s.license     = { :type => 'MIT' }
  s.authors     = { 'Marko Tadić' => 'https://twitter.com/tadija' }

  s.requires_arc = true
  s.osx.deployment_target = '10.9'
  s.ios.deployment_target = '8.0'
  s.source      = { :git => 'https://github.com/tadija/AEXML.git' }
  s.source_files = 'AEXML.swift'
end