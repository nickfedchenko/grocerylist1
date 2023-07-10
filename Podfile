# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'GroceryList' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'Amplitude'
  pod 'Alamofire'
  pod 'SwiftLint'
  pod 'GzipSwift'
  pod 'SnapKit'
  pod 'Kingfisher', '~> 7.6.1'
  pod 'ApphudSDK'
  pod 'R.swift'
  pod 'GzipSwift'
  pod 'PusherSwift', '~> 8.0'

  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/RemoteConfig'
  
  pod 'NVActivityIndicatorView'
  pod 'SFSafeSymbols', '~> 4.1.1'
  pod 'TagListView'
  
  # Pods for GroceryList

  post_install do |installer|
      installer.generated_projects.each do |project|
            project.targets.each do |target|
                target.build_configurations.each do |config|
                    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
                 end
            end
     end
  end
  
end
