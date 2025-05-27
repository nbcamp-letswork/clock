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
    private let fetchUseCase: FetchableStopwatchUseCase
    private let createUseCase: CreatableStopwatchUseCase
    private let deleteUseCase: DeletableStopwatchUseCase
    
    private let disposeBag = DisposeBag()
    private var timerDisposable: Disposable?
    
    let stopwatchState = BehaviorRelay<StopwatchState>(value: .idle)
    private let timer = BehaviorRelay<TimeInterval>(value: 0)
    private let lapsRelay = BehaviorRelay<[TimeInterval]>(value: [])
    
    // Input
    var startStopButtonTapped = PublishSubject<Void>()
    var lapRestButtonTapped = PublishSubject<Void>()
    var viewDidLoad = PublishSubject<Void>()
    var didEnterBackground = PublishSubject<Void>()
    
    // Output
    let lapsToDisplay: Observable<[StopwatchDisplay]>
    let timerToLabel: Observable<String>
    let leftButtonTitle: Observable<String>
    let isLapButtonEnable: Observable<Bool>
    
    init(
        fetchUseCase: FetchableStopwatchUseCase,
        createUseCase: CreatableStopwatchUseCase,
        deleteUseCase: DeletableStopwatchUseCase
    ) {
        self.fetchUseCase = fetchUseCase
        self.createUseCase = createUseCase
        self.deleteUseCase = deleteUseCase
        
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
                                lapNumber: laps.count - index,
                                lap: Self.convertTimerForLabel(time: lap),
                                type: .normal
                            )
                        }
                }
                
                let minTime = laps[1..<laps.count].min()!
                let maxTime = laps[1..<laps.count].max()!
                
                let minTimeIndex = laps[1..<laps.count].firstIndex(of: minTime)!
                let maxTimeIndex = laps[1..<laps.count].firstIndex(of: maxTime)!
                
                return laps.enumerated().map { index, time in
                    let type: LapType
                    if index == minTimeIndex {
                        type = .shortest
                    } else if index == maxTimeIndex {
                        type = .longest
                    } else {
                        type = .normal
                    }
                    
                    return StopwatchDisplay(
                        lapNumber: laps.count - index,
                        lap: Self.convertTimerForLabel(time: time),
                        type: index == 0 ? .normal : type
                    )
                }
            }
        
        bind()
    }
    
    private func bind() {
        stopwatchState
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                switch $0 {
                case .idle:
                    break
                case .paused:
                    stopTimer()
                case .running:
                    startTimer()
                }
            })
            .disposed(by: disposeBag)
        
        startStopButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                switch stopwatchState.value {
                case .idle:
                    addLap()
                    stopwatchState.accept(.running)
                case .paused:
                    stopwatchState.accept(.running)
                case .running:
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
        
        viewDidLoad
            .subscribe(onNext: { [weak self] in
                self?.fetchStopwatchPersistence()
            })
            .disposed(by: disposeBag)
        
        didEnterBackground
            .subscribe(onNext: { [weak self] in
                self?.createStopwatchPersistence()
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
        deleteStopwatchPersistence()
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
    
    func fetchStopwatchPersistence() {
        Task {
            do {
                let stopwatchPersistence = try await fetchUseCase.execute()
                if stopwatchPersistence.laps.count == 0 {
                    stopwatchState.accept(.idle)
                } else if stopwatchPersistence.isRunning == true {
                    stopwatchState.accept(.running)
                } else if stopwatchPersistence.isRunning == false {
                    stopwatchState.accept(.paused)
                }
                
                let sortedLaps = stopwatchPersistence.laps.sorted {
                    $0.lapNumber > $1.lapNumber
                }
                
                lapsRelay.accept(sortedLaps.map{ $0.time })
                timer.accept(stopwatchPersistence.laps.map{ $0.time }.reduce(0.0, +))
            } catch {
                print("fail fetch")
            }
        }
    }
    
    func createStopwatchPersistence() {
        Task {
            do {
                let laps = lapsRelay.value.enumerated().map { offset, time in
                    Lap(
                        lapNumber: lapsRelay.value.count - offset,
                        time: time
                    )
                }
                let isRunning = stopwatchState.value == .running ? true : false
                let stopwatch = Stopwatch(
                    isRunning: isRunning,
                    laps: laps
                )
                try await deleteUseCase.execute()
                try await createUseCase.execute(stopwatch: stopwatch)
            } catch {
                print("fail create")
            }
        }
    }
    
    func deleteStopwatchPersistence() {
        Task {
            do {
                try await deleteUseCase.execute()
            } catch {
                print("fail delete")
            }
        }
    }
}
