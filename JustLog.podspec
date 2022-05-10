Pod::Spec.new do |s|
  s.name             = 'JustLog'
  s.version          = '3.8.1'
  s.summary          = 'JustLog brings logging on iOS to the next level. It supports console, file and remote Logstash logging via TCP socket with no effort.'

  s.description      = "<<-DESC
  JustLog brings logging on iOS to the next level. It supports console, file and remote Logstash logging via TCP socket out of the box. You can setup JustLog to use [logz.io](http://logz.io) with no effort. JustLog relies on SwiftyBeaver, exposes a simple swifty API but it plays just fine also with Objective-C.
                         DESC"

  s.homepage         = 'https://github.com/justeat/JustLog'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = 'Just Eat Takeaway iOS Team'
  s.source           = { :git => 'https://github.com/justeat/JustLog.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/justeat_tech'

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.source_files = 'JustLog/Classes/**/*', 'JustLog/Extensions/**/*'

  s.dependency 'SwiftyBeaver', '~> 1.9.3'

end
