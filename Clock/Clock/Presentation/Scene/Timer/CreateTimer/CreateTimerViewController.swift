//
//  CreateTimerViewController.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit

final class CreateTimerViewController: UIViewController {
    private let timerView = CreateTimerView()

    override func loadView() {
        view = timerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
    }
}


private extension CreateTimerViewController {
    func setNavigationBar() {
        let editButton = BarButtonFactory.editButton()
        self.navigationItem.setLeftBarButton(editButton, animated: true)
        self.title = "타이머"
    }
}
