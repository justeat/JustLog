platform :ios, '9.0'
use_frameworks!

workspace 'JustLog.xcworkspace'

target 'Example' do
  project 'Example/Example.xcodeproj'

  pod 'JustLog', :path => './'

  target 'ExampleTests' do
    inherit! :search_paths

    
  end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == "JustLog"
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_TREAT_WARNINGS_AS_ERRORS'] = 'YES'
                config.build_settings['GCC_TREAT_WARNINGS_AS_ERRORS'] = 'YES'
            end
        end
    end
end
