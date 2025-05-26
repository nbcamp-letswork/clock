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
    private let fetchAllTimerUseCase: FetchableAllTimerUseCase
    private let createTimerUseCase: CreatableTimerUseCase

    private let disposeBag = DisposeBag()

    private let globalTick = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)

    // Input
    let viewDidLoad = PublishRelay<Void>()
    let createTimer = PublishRelay<(time: Int, label: String, sound: Sound)>()
    let toggleOrAddTimer = PublishRelay<UUID>()
    let deleteTimer = PublishRelay<IndexPath>()

    // Output
    let recentTimer = BehaviorRelay<[TimerDisplay]>(value: [])
    let ongoingTimer = BehaviorRelay<[TimerDisplay]>(value: [])
    let error = PublishRelay<Error>()

    init(
        fetchAllTimerUseCase: FetchableAllTimerUseCase,
        createTimerUseCase: CreatableTimerUseCase
    ) {
        self.fetchAllTimerUseCase = fetchAllTimerUseCase
        self.createTimerUseCase = createTimerUseCase
        bindInput()
        bindGlobalTick()
    }

    private func bindInput() {
        viewDidLoad
            .bind {[weak self] _ in
                self?.fetchTimers()
            }.disposed(by: disposeBag)

        createTimer
            .bind {[weak self] time, label, sound in
                self?.createTimer(time: time, label: label, sound: sound)
            }.disposed(by: disposeBag)

        toggleOrAddTimer
            .bind {[weak self] id in
                self?.toggleOrAddTimer(with: id)
            }.disposed(by: disposeBag)

        deleteTimer
            .bind { [weak self] indexPath in
                self?.deleteTimer(with: indexPath)
            }.disposed(by: disposeBag)
    }

    private func bindGlobalTick() {
        globalTick
            .subscribe { [weak self] _ in
                self?.updateTimersByTick()
            }.disposed(by: disposeBag)
    }

    private func updateTimersByTick() {
        var updatedTimers = ongoingTimer.value
        for (index, timer) in ongoingTimer.value.enumerated() where timer.isRunning {
            var updated = timer
            updated.reduceRemaining()
            updatedTimers[index] = updated
            if updated.remainingMillisecond == 0 {
                //TODO: 사운드 재생, coreData 저장
                updatedTimers.remove(at: index)
                print("사운드 재생: \(timer.id)")
                break
            }
        }

        ongoingTimer.accept(updatedTimers)
    }

    private func fetchTimers() {
        Task {
            do {
                let (ongoing, recent) = try await fetchAllTimerUseCase.execute()

                self.recentTimer.accept(
                     recent
                        .sorted(by: { $0.currentMilliseconds < $1.currentMilliseconds })
                        .map{ toTimerDisplay(timer: $0) }
                )
                self.ongoingTimer.accept(
                    ongoing
                        .sorted(by: { $0.currentMilliseconds < $1.currentMilliseconds })
                        .map{ toTimerDisplay(timer: $0) }
                )
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
                    label: label.isEmpty ? "" : label,
                )
                _ = try await createTimerUseCase.execute(timer: timer, isActive: true) // 재생
                _ = try await createTimerUseCase.execute(timer: timer, isActive: false) // 최근 항목

                let timerDisplay = toTimerDisplay(timer: timer)

                var updatedOngoing = ongoingTimer.value + [timerDisplay]
                updatedOngoing.sort { $0.remainingMillisecond < $1.remainingMillisecond }

                let recent = createNewTimer(with: timerDisplay, runningState: false)
                let recentDisplay = toTimerDisplay(timer: recent)
                var updatedRecent = recentTimer.value + [recentDisplay]
                updatedRecent.sort { $0.remainingMillisecond < $1.remainingMillisecond }

                ongoingTimer.accept(updatedOngoing)
                recentTimer.accept(updatedRecent)
            } catch {
                self.error.accept(error)
            }
        }
    }

    private func createNewTimer(with timerDisplay: TimerDisplay, runningState: Bool) -> Timer {
        return Timer(
            id: UUID(),
            milliseconds: timerDisplay.remainingMillisecond,
            isRunning: runningState,
            currentMilliseconds: timerDisplay.remainingMillisecond,
            sound: timerDisplay.sound,
            label: timerDisplay.label
        )
    }

    private func toggleOrAddTimer(with id: UUID) {
        // ongoingTimer에 존재한다면 토글, 없으면 RecentTimer를 ongoingTimer에 추가
        if let index = ongoingTimer.value.firstIndex(where: { $0.id == id }) {
            var timers = ongoingTimer.value
            var timer = timers[index]
            timer.toggleRunningState()
            timers[index] = timer
            ongoingTimer.accept(timers)
            return
        }

        guard let recent = recentTimer.value.first(where: {$0.id == id}) else {
            return
        }

        let timer = Timer(
            id: UUID(),
            milliseconds: recent.remainingMillisecond,
            isRunning: true,
            currentMilliseconds: recent.remainingMillisecond,
            sound: recent.sound,
            label: recent.label
        )
        let timerDisplay = toTimerDisplay(timer: timer)
        //TODO: Core Data에 ongoinTimer 추가
        var updatedOngoing = ongoingTimer.value + [timerDisplay]
        updatedOngoing.sort { $0.remainingMillisecond < $1.remainingMillisecond }
        ongoingTimer.accept(updatedOngoing)
        return
    }

    private func deleteTimer(with indexPath: IndexPath) {
        switch TimerSectionType(rawValue: indexPath.section) {
        case .ongoingTimer:
            var timers = ongoingTimer.value
            timers.remove(at: indexPath.row)
            ongoingTimer.accept(timers)
        case .recentTimer:
            var timers = recentTimer.value
            timers.remove(at: indexPath.row)
            recentTimer.accept(timers)
        default:
            return
        }
    }

    private func toTimerDisplay(timer: Timer) -> TimerDisplay {
        let label = timer.label.isEmpty ? TimerDisplayFormatter.formatToKoreanTimeString(
            millisecond: timer.milliseconds
        ) : timer.label

        return TimerDisplay(
            id: timer.id,
            label: label,
            remainingMillisecond: timer.currentMilliseconds,
            remainingTimeString: TimerDisplayFormatter.formatToDigitalTime(
                millisecond: timer.currentMilliseconds
            ),
            isRunning: timer.isRunning,
            sound: timer.sound
        )
    }
}
