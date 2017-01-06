Pod::Spec.new do |s|
  s.name         = "GridView"
  s.summary      = "GridView"
  s.homepage     = "https://github.com/KyoheiG3/GridView"
  s.version      = "0.1.0"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Kyohei Ito" => "je.suis.kyohei@gmail.com" }
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.source       = { :git => "https://github.com/KyoheiG3/GridView.git", :tag => s.version.to_s }
  s.source_files  = "GridView/**/*.{h,swift}"
  s.requires_arc = true
  s.frameworks = "UIKit"
end
