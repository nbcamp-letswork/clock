//
//  DefaultStopwatchViewModel.swift
//  Clock
//
//  Created by 유현진 on 5/22/25.
//

import Foundation
import RxSwift
import RxCocoa

fileprivate enum StopwatchState {
    case idle
    case running
    case paused
}

final class DefaultStopwatchViewModel: StopwatchViewModel {
    private let disposeBag = DisposeBag()
    private var timerDisposable: Disposable?
    
    private let stopwatchState = BehaviorRelay<StopwatchState>(value: .idle)
    private let timer = BehaviorRelay<TimeInterval>(value: 0)
    private let lapsRelay = BehaviorRelay<[TimeInterval]>(value: [])
    
    // Input
    var startStopButtonTapped = PublishSubject<Void>()
    var lapRestButtonTapped = PublishSubject<Void>()
    
    // Output
    let lapsToDisplay: Observable<[StopwatchDisplay]>
    let timerToLabel: Observable<String>
    let leftButtonTitle: Observable<String>
    let isLapButtonEnable: Observable<Bool>
    
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
        
        lapsToDisplay = lapsRelay
            .map { laps in
                guard laps.count > 2 else {
                    return laps
                        .enumerated()
                        .map { index, lap in
                            
                            StopwatchDisplay(
                                id: UUID(),
                                lapNumber: laps.count - index,
                                lap: Self.convertTimerForLabel(time: lap),
                                type: .normal
                            )
                        }
                }
                let minTime = laps[1..<laps.count].min()!
                let maxTime = laps[1..<laps.count].max()!
                
                return laps.enumerated().map { index, time in
                    let type: LapType
                    if time == minTime {
                        type = .shortest
                    } else if time == maxTime {
                        type = .longest
                    } else {
                        type = .normal
                    }
                    
                    return StopwatchDisplay(
                        id: UUID(),
                        lapNumber: laps.count - index,
                        lap: Self.convertTimerForLabel(time: time),
                        type: type
                    )
                }
            }
        
        bind()
    }

    private func bind() {
        startStopButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                switch stopwatchState.value {
                case .idle:
                    addLap()
                    startTimer()
                    stopwatchState.accept(.running)
                case .paused:
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
                } else if self?.stopwatchState.value == .running {
                    self?.addLap()
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
                updateFirstLap()
            }
    }
    
    func stopTimer() {
        timerDisposable?.dispose()
    }
    
    func resetTimer() {
        stopwatchState.accept(.idle)
        timer.accept(0)
        lapsRelay.accept([])
    }
    
    func addLap() {
        var currentLaps = lapsRelay.value
        let newLap = TimeInterval(0)
        currentLaps.insert(newLap, at: 0)
        lapsRelay.accept(currentLaps)
    }
    
    func updateFirstLap() {
        var currentLaps = lapsRelay.value
        guard !currentLaps.isEmpty else { return }
        currentLaps[0] += 0.01
        lapsRelay.accept(currentLaps)
    }
}
