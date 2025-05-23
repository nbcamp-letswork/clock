//
//  BaseTabBarViewController.swift
//  Clock
//
//  Created by 유현진 on 5/21/25.
//

import UIKit

final class BaseTabBarViewController: UITabBarController {
    let diContainer: DIContainer

    init(diContainer: DIContainer) {
        self.diContainer = diContainer

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

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
            let vm = diContainer.makeAlarmViewModel()
            let vc = AlarmViewController(alarmViewModel: vm)
            let nav = UINavigationController(rootViewController: vc)
            nav.tabBarItem = makeTabBarItem(type: type)
            return nav
        case .stopwatch:
            let vc = StopwatchViewController()
            vc.tabBarItem = makeTabBarItem(type: type)
            return vc
        case .timer:
            let vm = diContainer.makeTimerViewModel()
            let vc = TimerViewController(viewModel: vm)
            let nav = UINavigationController(rootViewController: vc)
            nav.tabBarItem = makeTabBarItem(type: type)
            return nav
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
