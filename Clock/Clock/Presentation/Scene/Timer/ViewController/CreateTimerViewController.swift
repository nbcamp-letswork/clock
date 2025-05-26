//
//  CreateTimerViewController.swift
//  Clock
//
//  Created by 이수현 on 5/25/25.
//

import UIKit
import RxSwift

final class CreateTimerViewController: UIViewController {
    private let createTimerView = OngoingTimerHeaderView()
    private let viewModel: TimerViewModel

    private let disposeBag = DisposeBag()

    override func loadView() {
        view = createTimerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        setNavigationBar()
        setBindings()
    }

    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension CreateTimerViewController {
    func setAttributes() {
        createTimerView.setHiddenButton()
    }

    func setBindings() {
        navigationItem.leftBarButtonItem?.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: true)
            }.disposed(by: disposeBag)

        navigationItem.rightBarButtonItem?.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .withLatestFrom(createTimerView.createdTimer)
            .compactMap { $0 }
            .bind { [weak self] timerInfo in
                guard let self, timerInfo.time != 0 else { return }
                createTimerView.endEditing(true)
                viewModel.createTimer.accept(timerInfo)
                dismiss(animated: true)
            }.disposed(by: disposeBag)
    }

    func setNavigationBar() {
        let cancelButton = BarButtonFactory.customButton(with: "취소")
        let startButton = BarButtonFactory.customButton(with: "시작")
        self.navigationItem.setLeftBarButton(cancelButton, animated: true)
        self.navigationItem.setRightBarButton(startButton, animated: true)
        self.title = "타이머"
    }
}
