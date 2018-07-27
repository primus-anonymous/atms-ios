# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'atms' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Alamofire', '~> 4.7'
  pod 'RxSwift',    '~> 4.0'
  pod 'RxCocoa',    '~> 4.0'
  pod 'Swinject'
  pod 'SwinjectStoryboard'
  pod 'Pulley'

  # Pods for atms

  target 'atmsTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Cuckoo'
    pod 'RxBlocking', '~> 4.0'
    pod 'RxTest',     '~> 4.0'
  end

  target 'atmsUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
