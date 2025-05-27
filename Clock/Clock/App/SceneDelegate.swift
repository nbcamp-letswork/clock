//
//  SceneDelegate.swift
//  Clock
//
//  Created by youseokhwan on 5/20/25.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions,
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
         window = UIWindow(windowScene: windowScene)
         window?.backgroundColor = .background

         let diContainer = DIContainer()
         if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
             appDelegate.diContainer = diContainer
         }

         window?.rootViewController = BaseTabBarViewController(diContainer: diContainer)
         window?.makeKeyAndVisible()

         NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAlarmNotificationTap(_:)),
            name: .didTapAlarmNotification,
            object: nil
         )
    }

    func sceneWillResignActive(_ scene: UIScene) {
        NotificationCenter.default.post(
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        NotificationCenter.default.removeObserver(self, name: .didTapAlarmNotification, object: nil)
    }

    @objc
    private func handleAlarmNotificationTap(_ notification: Notification) {
        guard let tabBarController = window?.rootViewController as? BaseTabBarViewController
        else {
            return
        }

        tabBarController.selectedIndex = 0
    }
}
