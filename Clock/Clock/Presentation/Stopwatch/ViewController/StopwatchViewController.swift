//
//  StopwatchViewController.swift
//  Clock
//
//  Created by 유현진 on 5/21/25.
//

import UIKit
import RxSwift
import RxCocoa

final class StopwatchViewController: UIViewController {
    private let stopwatchView = StopwatchView()
    private let disposeBag = DisposeBag()
    private let viewModel = DefaultStopwatchViewModel()
    
    override func loadView() {
        view = stopwatchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBindings()
    }
}

private extension StopwatchViewController {
    func setBindings() {
        stopwatchView.startButton.rx
            .tap
            .subscribe { [weak self] _ in
                guard let self else { return }
                if stopwatchView.startButton.isSelected {
                    viewModel.startButtonTapped.onNext(())
                } else {
                    viewModel.stopButtonTapped.onNext(())
                }
            }
            .disposed(by: disposeBag)
        
        stopwatchView.lapButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                viewModel.lapButtonTapped.onNext(())
            })
            .disposed(by: disposeBag)
        
        viewModel.timerToLabel
            .asDriver(onErrorJustReturn: "00:00.00")
            .drive(stopwatchView.timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.leftButtonTitle
            .asDriver(onErrorDriveWith: .empty())
            .drive(stopwatchView.lapButton.rx.title())
            .disposed(by: disposeBag)
        
        viewModel.isLapButtonEnable
            .asDriver(onErrorDriveWith: .empty())
            .drive(stopwatchView.lapButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
