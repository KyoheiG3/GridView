Pod::Spec.new do |s|
  s.name         = "G3GridView"
  s.summary      = "Reusable GridView with excellent performance and customization that can be time table, spreadsheet, paging and more."
  s.homepage     = "https://github.com/KyoheiG3/GridView"
  s.version      = "0.7.0"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Kyohei Ito" => "je.suis.kyohei@gmail.com" }
  s.swift_version = '5.0'
  s.ios.deployment_target = '9.0'
  s.source       = { :git => "https://github.com/KyoheiG3/GridView.git", :tag => s.version.to_s }
  s.source_files = "GridView/**/*.{h,m,swift}"
  s.module_name = "GridView"
  s.requires_arc = true
  s.frameworks = "UIKit"
end
