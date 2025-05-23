//
//  DefaultStopwatchViewModel.swift
//  Clock
//
//  Created by 유현진 on 5/22/25.
//

import Foundation
import RxSwift
import RxCocoa

final class DefaultStopwatchViewModel: StopwatchViewModel {
    private let disposeBag = DisposeBag()
    var timerDisposable: Disposable?
    
    var timer = BehaviorRelay<TimeInterval>(value: 0)
    
    var startButtonTapped = PublishSubject<Void>()
    var stopButtonTapped = PublishSubject<Void>()
    
    var timerToLabel: Observable<String>
    
    
    init() {
        timerToLabel = timer.map { Self.convertTimerForLabel(time: $0) }
        
        bind()
    }

    private func bind() {
        startButtonTapped
            .subscribe(onNext: { [weak self] _ in
                self?.startTimer()
            })
            .disposed(by: disposeBag)
        
        stopButtonTapped
            .subscribe(onNext: { [weak self] _ in
                self?.stopTimer()
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
}
