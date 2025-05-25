//
//  DefaultTimerViewModel.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit
import RxSwift
import RxRelay

final class DefaultTimerViewModel: TimerViewModel {
    private let fetchRecentTimerUseCase: FetchableRecentTimerUseCase
    private let fetchOngoingTimerUseCase: FetchableOngoingTimerUseCase
    private let createTimerUseCase: CreatableTimerUseCase

    private let disposeBag = DisposeBag()

    private var remainingTime: [UUID: BehaviorSubject<Int>] = [:]
    private let globalTick = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)

    // Input
    let viewDidLoad = PublishRelay<Void>()
    let createTimer = PublishRelay<(time: Int, label: String, sound: Sound)>()
    let startTimer = PublishRelay<UUID>()

    // Output
    let recentTimer = BehaviorRelay<[TimerDisplay]>(value: [])
    let ongoingTimer = BehaviorRelay<[TimerDisplay]>(value: [])
    let error = PublishRelay<Error>()

    init(
        fetchRecentTimerUseCase: FetchableRecentTimerUseCase,
        fetchOngoingTimerUseCase: FetchableOngoingTimerUseCase,
        createTimerUseCase: CreatableTimerUseCase
    ) {
        self.fetchRecentTimerUseCase = fetchRecentTimerUseCase
        self.fetchOngoingTimerUseCase = fetchOngoingTimerUseCase
        self.createTimerUseCase = createTimerUseCase
        bindInput()
        bindGlobalTick()
    }

    private func bindInput() {
        viewDidLoad
            .bind {[weak self] _ in
                self?.fetchTimer()
            }.disposed(by: disposeBag)

        createTimer
            .bind {[weak self] time, label, sound in
                self?.createTimer(time: time, label: label, sound: sound)
            }.disposed(by: disposeBag)

        startTimer
            .bind {[weak self] id in
                self?.toggleIsRunning(id: id)
            }.disposed(by: disposeBag)
    }

    private func bindGlobalTick() {
        globalTick
            .subscribe { [weak self] _ in
                self?.tickAllTimers()
            }.disposed(by: disposeBag)
    }

    private func tickAllTimers() {
        var updatedTimers = ongoingTimer.value
        for (index, timer) in ongoingTimer.value.enumerated() where timer.isRunning {
            let newTime = max(0, timer.remainingMillisecond - 1000)
            var updated = timer
            updated.reduceRemaining()
            updatedTimers[index] = updated
            if newTime == 0 {
                //TODO: 사운드 재생, coreData 저장
                updatedTimers.remove(at: index)
                print("사운드 재생: \(timer.id)")
                break
            }
        }

        ongoingTimer.accept(updatedTimers)
    }

    private func fetchTimer() {
        Task {
            do {
                async let recentTimer = fetchRecentTimerUseCase.execute()
                async let ongoingTimer = fetchOngoingTimerUseCase.execute()

                self.recentTimer.accept(try await recentTimer.map{ toTimerDisplay(timer: $0) })
                self.ongoingTimer.accept(try await ongoingTimer.map{ toTimerDisplay(timer: $0) })
            } catch {
                self.error.accept(error)
            }
        }
    }

    private func createTimer(time: Int, label: String, sound: Sound) {
        let id = UUID()
        //TODO: CoreData 저장(recent, ongoing), 불러오기, 생성한 타이머 실행

        Task {
            do {
                let timer = Timer(
                    id: id,
                    milliseconds: time,
                    isRunning: true,
                    currentMilliseconds: time,
                    sound: sound,
                    label: label.isEmpty ? nil : label
                )
                _ = try await createTimerUseCase.execute(timer: timer)
            } catch {
                self.error.accept(error)
            }
        }
    }

    private func toggleIsRunning(id: UUID) {
        var updatedTimer = ongoingTimer.value
        guard let timerIndex = ongoingTimer.value.firstIndex(where: {$0.id == id}) else {
            return
        }
        var newTimerDisplay = updatedTimer[timerIndex]
        newTimerDisplay.isRunnigToggle()
        updatedTimer[timerIndex] = newTimerDisplay
        ongoingTimer.accept(updatedTimer)
    }

    private func toTimerDisplay(timer: Timer) -> TimerDisplay {
        TimerDisplay(
            id: timer.id,
            label: timer.label ?? TimerDisplayFormatter.formatToKoreanTimeString(
                millisecond: timer.milliseconds
            ),
            remainingMillisecond: timer.currentMilliseconds,
            remainingTimeString: TimerDisplayFormatter.formatToDigitalTime(
                millisecond: timer.currentMilliseconds
            ),
            isRunning: timer.isRunning
        )
    }
}
