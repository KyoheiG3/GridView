Pod::Spec.new do |s|
  s.name         = "G3GridView"
  s.summary      = "Reusable GridView with excellent performance and customization that can be time table, spreadsheet, paging and more."
  s.homepage     = "https://github.com/KyoheiG3/GridView"
  s.version      = "0.5.1"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Kyohei Ito" => "je.suis.kyohei@gmail.com" }
  s.swift_version = '4.2'
  s.ios.deployment_target = '9.0'
  s.source       = { :git => "https://github.com/KyoheiG3/GridView.git", :tag => s.version.to_s }
  s.source_files  = "GridView/**/*.{h,swift}"
  s.requires_arc = true
  s.frameworks = "UIKit"
end
