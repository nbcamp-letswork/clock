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
    
    private let stopwatchStateRelay = BehaviorRelay<StopwatchState>(value: .idle)
    private let timer = BehaviorRelay<TimeInterval>(value: 0)
    private let lapsRelay = BehaviorRelay<[TimeInterval]>(value: [])
    private let recentLapRelay = BehaviorRelay<TimeInterval?>(value: nil)
    
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
    var stopwatchState: Observable<StopwatchState> { stopwatchStateRelay.asObservable() }
    
    lazy var recentLap: Observable<StopwatchDisplay?> = {
        recentLapRelay
            .map { [weak self] lap -> StopwatchDisplay? in
                guard let self, let lap else { return nil }
                return StopwatchDisplay(
                    lapNumber: lapsRelay.value.count,
                    lap: Self.convertTimerForLabel(time: lap),
                    type: .normal
                )
            }
    }()
    
    init(
        fetchUseCase: FetchableStopwatchUseCase,
        createUseCase: CreatableStopwatchUseCase,
        deleteUseCase: DeletableStopwatchUseCase
    ) {
        self.fetchUseCase = fetchUseCase
        self.createUseCase = createUseCase
        self.deleteUseCase = deleteUseCase
        
        timerToLabel = timer.map { Self.convertTimerForLabel(time: $0) }
        leftButtonTitle = stopwatchStateRelay
            .map {
                switch $0 {
                case .idle, .running:
                    return "랩"
                case .paused:
                    return "재설정"
                }
            }
        
        isLapButtonEnable = stopwatchStateRelay
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
        stopwatchStateRelay
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
                switch stopwatchStateRelay.value {
                case .idle:
                    addLap()
                    stopwatchStateRelay.accept(.running)
                case .paused:
                    stopwatchStateRelay.accept(.running)
                case .running:
                    stopwatchStateRelay.accept(.paused)
                }
            })
            .disposed(by: disposeBag)
        
        lapRestButtonTapped
            .subscribe(onNext: { [weak self] _ in
                if self?.stopwatchStateRelay.value == .paused {
                    self?.resetTimer()
                } else if self?.stopwatchStateRelay.value == .running {
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
                updateRecentLap()
            }
    }
    
    func stopTimer() {
        timerDisposable?.dispose()
    }
    
    func resetTimer() {
        stopwatchStateRelay.accept(.idle)
        timer.accept(0)
        lapsRelay.accept([])
        deleteStopwatchPersistence()
    }
    
    func addLap() {
        var currentLaps = lapsRelay.value
        if let recentLap = recentLapRelay.value,
           !currentLaps.isEmpty {
            currentLaps[0] = recentLap
        }
        
        let newLap = TimeInterval(0)
        currentLaps.insert(newLap, at: 0)
        lapsRelay.accept(currentLaps)
        
        recentLapRelay.accept(0)
    }
    
    func updateRecentLap() {
        guard var currentLap = recentLapRelay.value else { return }
        currentLap += 0.01
        
        recentLapRelay.accept(currentLap)
    }
}

private extension DefaultStopwatchViewModel {
    func fetchStopwatchPersistence() {
        Task {
            guard let stopwatchPersistence = try? await fetchUseCase.execute() else {
                return
            }
            if stopwatchPersistence.laps.count == 0 {
                stopwatchStateRelay.accept(.idle)
            } else if stopwatchPersistence.isRunning == true {
                stopwatchStateRelay.accept(.running)
            } else if stopwatchPersistence.isRunning == false {
                stopwatchStateRelay.accept(.paused)
            }
            
            let sortedLaps = stopwatchPersistence.laps.sorted {
                $0.lapNumber > $1.lapNumber
            }
            
            lapsRelay.accept(sortedLaps.map{ $0.time })
            if !lapsRelay.value.isEmpty {
                recentLapRelay.accept(lapsRelay.value[0])
            }
            timer.accept(stopwatchPersistence.laps.map{ $0.time }.reduce(0.0, +))
        }
    }
    
    func createStopwatchPersistence() {
        Task {
            var currentLaps = lapsRelay.value
            if let recentLap = recentLapRelay.value,
               !currentLaps.isEmpty {
                currentLaps[0] = recentLap
            }
            
            let laps = currentLaps.enumerated().map { offset, time in
                Lap(
                    lapNumber: lapsRelay.value.count - offset,
                    time: time
                )
            }
            let isRunning = stopwatchStateRelay.value == .running ? true : false
            let stopwatch = Stopwatch(
                isRunning: isRunning,
                laps: laps
            )
            try? await deleteUseCase.execute()
            try? await createUseCase.execute(stopwatch: stopwatch)
        }
    }
    
    func deleteStopwatchPersistence() {
        Task {
            try? await deleteUseCase.execute()
        }
    }
}
