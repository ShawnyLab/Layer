//
//  AppDelegate.swift
//  Layer
//
//  Created by 박진서 on 2022/07/15.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {


    var window: UIWindow?

    override init() {
        super.init()
        UIFont.overrideInitialize()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        FirebaseApp.configure()
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "defaultVC") as! DefaultViewController
        let nav = UINavigationController(rootViewController: vc)
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC") as! MainViewController
//        let nav = UINavigationController(rootViewController: vc)
//        nav.navigationBar.isHidden = true
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        
        Messaging.messaging().delegate = self // [메시징 딜리게이트 지정]
        UNUserNotificationCenter.current().delegate = self // [노티피케이션 알림 딜리게이트 지정]
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound] // [푸시 알림 권한]

        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in // [푸시 알림 권한 요청]
            // [success 부분에 권한을 허락하면 true / 권한을 허락하지 않으면 false 값이 들어갑니다]
            if let error = error {
                print("")
                print("===============================")
                print("[AppDelegate >> requestAuthorization() :: 노티피케이션 권한 요청 에러]")
                print("[error :: \(error.localizedDescription)]")
                print("===============================")
                print("")
            }
            else {
                print("")
                print("===============================")
                print("[AppDelegate >> requestAuthorization() :: 노티피케이션 권한 요청 응답 확인]")
                print("[success :: \(success)]")
                print("===============================")
                print("")
            }
        }
        
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // 세로방향 고정
        return UIInterfaceOrientationMask.portrait
    }

    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }


}

