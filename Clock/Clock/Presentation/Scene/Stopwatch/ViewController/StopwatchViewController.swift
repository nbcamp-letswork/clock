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
    private let viewModel: StopwatchViewModel
    
    init(viewModel: StopwatchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = stopwatchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBindings()
        viewModel.viewDidLoad.onNext(())
    }
}

private extension StopwatchViewController {
    func setBindings() {
        viewModel.lapsToDisplay
            .asDriver(onErrorJustReturn: [])
            .drive(stopwatchView.lapTableView.rx.items(
                cellIdentifier: LapTableViewCell.identifier,
                cellType: LapTableViewCell.self
            )) { _, model, cell in
                cell.configure(model: model)
            }
            .disposed(by: disposeBag)
        
        viewModel.stopwatchState
            .bind { [weak self] in
                switch $0 {
                case .running:
                    self?.stopwatchView.startStopButton.isSelected = true
                case .paused:
                    self?.stopwatchView.startStopButton.isSelected = false
                default: break
                }
            }
            .disposed(by: disposeBag)
        
        stopwatchView.startStopButton.rx
            .tap
            .subscribe { [weak self] _ in
                guard let self else { return }
                viewModel.startStopButtonTapped.onNext(())
            }
            .disposed(by: disposeBag)
        
        stopwatchView.lapResetButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                viewModel.lapRestButtonTapped.onNext(())
            })
            .disposed(by: disposeBag)
        
        viewModel.timerToLabel
            .asDriver(onErrorJustReturn: "00:00.00")
            .drive(stopwatchView.timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.leftButtonTitle
            .asDriver(onErrorDriveWith: .empty())
            .drive(stopwatchView.lapResetButton.rx.title())
            .disposed(by: disposeBag)
        
        viewModel.isLapButtonEnable
            .asDriver(onErrorDriveWith: .empty())
            .drive(stopwatchView.lapResetButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                viewModel.didEnterBackground.onNext(())
            })
            .disposed(by: disposeBag)
    }
}
