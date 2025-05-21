//
//  BaseTabBarViewController.swift
//  Clock
//
//  Created by 유현진 on 5/21/25.
//

import UIKit

final class BaseTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
    }
    
    private func start() {
        let tabs: [TabBarItemType] = TabBarItemType.allCases
        let controllers = tabs.map { makeViewController(type: $0) }
       
        configureTabController(viewControllers: controllers)
    }
    
    private func makeViewController(type: TabBarItemType) -> UIViewController {
        switch type {
        case .alarm:
            let vc = ViewController() // TODO: 지성님 수정
            vc.tabBarItem = makeTabBarItem(type: type)
            return vc
        case .stopwatch:
            let vc = ViewController()
            vc.tabBarItem = makeTabBarItem(type: type)
            return vc
        case .timer:
            let vc = ViewController() // TODO: 수현님 수정
            vc.tabBarItem = makeTabBarItem(type: type)
            return vc
        }
    }
    
    private func makeTabBarItem(type: TabBarItemType) -> UITabBarItem {
        UITabBarItem(
            title: type.title,
            image: UIImage(systemName: type.imageName),
            tag: type.index
        )
    }

    
    private func configureTabController(viewControllers: [UIViewController]) {
        setViewControllers(viewControllers, animated: false)
        selectedIndex = 0 // TODO: 마지막 화면 저장
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .systemOrange
    }
}
