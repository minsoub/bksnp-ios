//
//  SceneDelegate.swift
//  bksnpios
//
//  Created by hist on 2021/12/26.
//

import UIKit
import FirebaseDynamicLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        //앱이 종료된 경우(폰에서 해당 앱을 swipe up) 동적 링크를 클릭시 콜백 함수가 호출되지 않는 이슈 수정
        for userActivity in connectionOptions.userActivities {
            if let incomingURL = userActivity.webpageURL{
                print("Incoming URL is \(incomingURL)")
                let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                            guard error == nil else{
                                print("Found an error \(error!.localizedDescription)")
                                return
                            }
                            if dynamicLink == dynamicLink{
                                self.handelIncomingDynamicLink(_dynamicLink: dynamicLink!)
                            }
                        }
                print(linkHandled)
                break
            }
        }
                
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    

        

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print("Activate");
        let msg = "activate"
        NotificationCenter.default.post(name: NSNotification.Name(Constants.activateMessageKey), object: msg, userInfo: nil)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print("Deactivate");
        let msg = "deactivate"
        NotificationCenter.default.post(name: NSNotification.Name(Constants.activateMessageKey), object: msg, userInfo: nil)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

    }
    
    // 동적 링크를 수신하기 위한 코드
    func handelIncomingDynamicLink(_dynamicLink: DynamicLink) {
        guard let url = _dynamicLink.url else {
            print("That is weird. my dynamic link object has no url")
            return
        }
        print("plusapps SceneDelegate your incoming link perameter is \(url.absoluteString)")
          
        _dynamicLink.matchType
        //앱이 처음 실행될 때에는 Notification이 등록되지 않아서 동적 링크처리를 못하므로
        //Constants.firebaseDynamicLink를 사용하여 처리
        Constants.firebaseDynamicLink = url.absoluteString
            
        // ViewController notification
        NotificationCenter.default.post(name: Notification.Name(rawValue: "clickFirebaseDynamicLink"), object: url.absoluteString)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let incomingURL = userActivity.webpageURL{
            print("Incoming URL is \(incomingURL)")
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                guard error == nil else{
                    print("Found an error \(error!.localizedDescription)")
                    return
                }
                if dynamicLink == dynamicLink{
                    self.handelIncomingDynamicLink(_dynamicLink: dynamicLink!)
                }
            }
            print(linkHandled)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url{
            print("url:-   \(url)")
            if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url){
                 self.handelIncomingDynamicLink(_dynamicLink: dynamicLink)
                 //return true
            } else{
             // maybe handel Google and firebase
             print("False")
            }

        }
    }
}

