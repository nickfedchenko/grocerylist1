# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '14.0'

def base_pods
  pod 'Amplitude'
  pod 'Alamofire'
  pod 'SwiftLint'
  pod 'GzipSwift'
  pod 'SnapKit'
  pod 'Kingfisher', '~> 7.6.1'
  pod 'R.swift'
  pod 'PusherSwift', '~> 8.0'
  pod 'ApphudSDK'
end

target 'GroceryList' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  base_pods

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
          config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'No'
        end
      end
    end
  end
  
end

################################
# iOS ACTION EXTENSION
target 'ActionExtension' do
    use_frameworks!
    base_pods
    
end
