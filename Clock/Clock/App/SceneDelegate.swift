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
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
    }
}
