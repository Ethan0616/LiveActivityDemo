//
//  AppDelegate.swift
//  LiveActivityDemo
//
//  Created by Ethan on 2022/10/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // register notification
        if #available(iOS 10.0, *) {
//            LiveActivityInterface<PizzaDeliveryAttributes>.shared()
                   let center = UNUserNotificationCenter.current()
                   center.delegate = self as UNUserNotificationCenterDelegate
                   center.getNotificationSettings { (setting) in
                       if setting.authorizationStatus == .notDetermined{
                           // 未注册
                           center.requestAuthorization(options: [.badge,.sound,.alert]) { (result, error) in
                               print("显示内容：\(result) error：\(String(describing: error))")
                               if(result){
                                   if !(error != nil){
                                       print("注册成功了！")
                            
                                       DispatchQueue.main.async {
                                           UIApplication.shared.registerForRemoteNotifications()
                                       }
                                   }
                               } else{
                                   print("用户不允许推送")
                               }
                           }
                       } else if (setting.authorizationStatus == .denied){
                           //用户已经拒绝推送通知
                           //-- 弹出页面提示用户去显示
                           
                       }else if (setting.authorizationStatus == .authorized){
                           //已注册 已授权 --注册同志获取 token
//                           self.registerForRemoteNotifications()
//                           UNUserNotificationCenter.requestAuthorization(self)
                           DispatchQueue.main.async {
                               UIApplication.shared.registerForRemoteNotifications()
                           }
                       }else{
                           DispatchQueue.main.async {
                               UIApplication.shared.registerForRemoteNotifications()
                           }
                       }
                   }
        } else {
            // Fallback on earlier versions
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        
        return true
    }
    
    // noti
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("\n ================================== \n 我的deviceToken:【\(deviceToken.map{ String(format: "%02.2hhx", $0) }.joined())】\n ==================================")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("\n ================================== \n 收到的信息为: ==================================【\(response.notification)】\n ==================================")
        
        guard LiveActivityInterface<VJLiveActivityAttributes>.alreadyHaveLiveActivity() else { return }
        
        let gameState = VJLiveActivityAttributes.VJAttributesState(timestamp: "", driverName: "Ethan", courier: "", numberOfPizzas: "",Score: "20",originScore: "0", totalAmount:"", avatar: "person.circle", deliveryState: VJLiveActivityAttributesState.completed)
        do {
            try LiveActivityInterface<VJLiveActivityAttributes>.update(contentState: gameState,nickNmae: "")
        } catch (let error) {
            print(error)
        }
    }
    


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

