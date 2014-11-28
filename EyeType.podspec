Pod::Spec.new do |s|
  s.name             = "EyeType"
  s.version          = "0.0.1"
  s.summary          = ""
  s.description      = <<-DESC

                       DESC
  s.homepage         = "https://github.com/scvsoft/EyeType-iOS/blob/master/README.md"
  s.license          = 'GNU Lesser General Public License 3'
  s.author           = { "hhsaez" => "hernan@scvsoft.com" }
  s.source           = { :git => "https://github.com/scvsoft/widgetorium_ios.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/scvsoft'

  s.platform     = :ios, '6.1.3'
  s.ios.deployment_target = '6.1.3'
  s.requires_arc = true
  s.libraries = 'sqlite3'
  s.dependency 'OpenCV', '~> 2.4.9.1'

  s.source_files = 'EyeType/EyeType/{ETRect,ETBlinkDetector,ETMovementDetector*,ETVideoSourceView*,VideoSource,GLESImageView}.{h,m,mm}'
  
end
