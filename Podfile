# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Layer' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Layer
  pod 'Mantis', '~> 2.3.0'
  pod 'Firebase/Analytics'
  pod 'FSPagerView'
  pod 'FBSDKLoginKit', '~> 14.0'
  pod 'SnapKit'
  pod 'Then'
  pod 'Alamofire'  
  pod 'RxGesture'
  pod 'RxSwift', '~> 5.1.1'
  pod 'RxCocoa'
  pod 'RxViewController'
  pod 'Action'
  pod 'NSObject+Rx'
  pod 'Kingfisher'
  pod 'ObjectMapper'
  pod 'Firebase/Auth'
  pod 'Firebase/Messaging'
  pod 'Firebase/Analytics'
  pod 'Firebase/Storage'
  pod 'Firebase/Database'
  pod 'Firebase/Firestore'
  pod 'lottie-ios'
  pod 'Reusable'
  pod 'RxGesture'
  pod 'Moya'
  pod 'SkeletonView'
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
        target.build_configurations.each do |config|
            config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        end
      end
    end
  end
end 

  
end
