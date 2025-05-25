//
//  DefaultStopwatchViewModel.swift
//  Clock
//
//  Created by 유현진 on 5/22/25.
//

import Foundation
import RxSwift
import RxCocoa

enum StopwatchState {
    case idle
    case running
    case paused
}

final class DefaultStopwatchViewModel: StopwatchViewModel {
    private let disposeBag = DisposeBag()
    var timerDisposable: Disposable?
    
    private let stopwatchState = BehaviorRelay<StopwatchState>(value: .idle)
    var timer = BehaviorRelay<TimeInterval>(value: 0)
    
    // Input
    var startStopButtonTapped = PublishSubject<Void>()
    var lapRestButtonTapped = PublishSubject<Void>()
    
    // Output
    var timerToLabel: Observable<String>
    var leftButtonTitle: Observable<String>
    var isLapButtonEnable: Observable<Bool>
    
    init() {
        timerToLabel = timer.map { Self.convertTimerForLabel(time: $0) }
        leftButtonTitle = stopwatchState
            .map {
                switch $0 {
                case .idle, .running:
                    return "랩"
                case .paused:
                    return "재설정"
                }
            }
        isLapButtonEnable = stopwatchState            
            .map {
                switch $0 {
                case .idle:
                    return false
                case .paused, .running:
                    return true
                }
            }
        bind()
    }

    private func bind() {
        startStopButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                switch stopwatchState.value {
                case .idle, .paused:
                    startTimer()
                    stopwatchState.accept(.running)
                case .running:
                    stopTimer()
                    stopwatchState.accept(.paused)
                }
            })
            .disposed(by: disposeBag)
        
        lapRestButtonTapped
            .subscribe(onNext: { [weak self] _ in
                if self?.stopwatchState.value == .paused {
                    self?.resetTimer()
                }
            })
            .disposed(by: disposeBag)
    }
}

private extension DefaultStopwatchViewModel {
    static func convertTimerForLabel(time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let centiseconds = Int((time - floor(time)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, centiseconds)
    }
    
    func startTimer() {
        timerDisposable = Observable<Int>.interval(.milliseconds(10), scheduler: MainScheduler.instance)
            .subscribe { [weak self] time in
                guard let self else { return }
                let newValue = timer.value + 0.01
                timer.accept(newValue)
            }
    }
    
    func stopTimer() {
        timerDisposable?.dispose()
    }
    
    func resetTimer() {
        stopwatchState.accept(.idle)
        timer.accept(0)
    }
}
