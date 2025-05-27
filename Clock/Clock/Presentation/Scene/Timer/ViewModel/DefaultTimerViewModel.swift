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
    private let deleteTimerUseCase: DeletableTimerUseCase
    private let updateTimerUseCase: UpdatableTimerUseCase

    private let disposeBag = DisposeBag()

    private let globalTick = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    private let timerUpdateQueue = DispatchQueue(label: "com.clock.timerUpdateQueue")

    // Input
    let viewDidLoad = PublishRelay<Void>()
    let createTimer = PublishRelay<(time: Int, label: String, sound: SoundDisplay)>()
    let toggleOrAddTimer = PublishRelay<UUID>()
    let deleteTimer = PublishRelay<IndexPath>()
    let saveTimers = PublishRelay<Void>()
    let updatedSound = PublishRelay<SoundDisplay>()


    // Output
    let recentTimer = BehaviorRelay<[TimerDisplay]>(value: [])
    let ongoingTimer = BehaviorRelay<[TimerDisplay]>(value: [])
    let currentSound = BehaviorRelay<SoundDisplay>(value: .bell)
    let error = PublishRelay<Error>()

    init(
        fetchAllTimerUseCase: FetchableAllTimerUseCase,
        createTimerUseCase: CreatableTimerUseCase,
        deleteTimerUseCase: DeletableTimerUseCase,
        updateTimerUseCase: UpdatableTimerUseCase
    ) {
        self.fetchAllTimerUseCase = fetchAllTimerUseCase
        self.createTimerUseCase = createTimerUseCase
        self.deleteTimerUseCase = deleteTimerUseCase
        self.updateTimerUseCase = updateTimerUseCase
        bindInput()
        bindGlobalTick()
    }

    private func bindInput() {
        viewDidLoad
            .bind {[weak self] in
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
                self?.deleteTimer(at: indexPath)
            }.disposed(by: disposeBag)

        saveTimers
            .bind { [weak self] in
                self?.saveCurrentTimers()
            }.disposed(by: disposeBag)

        updatedSound
            .bind(to: currentSound)
            .disposed(by: disposeBag)
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
                //TODO: 사운드 재생
                let timer = updatedTimers.remove(at: index)
                deleteTimerFromStorage(id: timer.id)
                print("사운드 재생: \(timer.id)")
                break
            }
        }

        timerUpdateQueue.async {
            self.ongoingTimer.accept(updatedTimers)
        }
    }

    private func fetchTimers() {
        Task {
            do {
                let (ongoing, recent) = try await fetchAllTimerUseCase.execute()
                updateSortedTimerDisplayRelay(with: ongoing.map{ TimerMapper.mapToDisplay(timer: $0) }, to: ongoingTimer)
                updateSortedTimerDisplayRelay(with: recent.map{ TimerMapper.mapToDisplay(timer: $0) }, to: recentTimer)
            } catch {
                self.error.accept(error)
            }
        }
    }

    private func saveCurrentTimers() {
        Task {
            await withTaskGroup { group in
                let timerDisplays = recentTimer.value + ongoingTimer.value
                for timerDisplay in timerDisplays {
                    let timer = TimerMapper.mapToModel(display: timerDisplay)
                    group.addTask { [weak self] in
                        try? await self?.updateTimerUseCase.execute(timer: timer)
                    }
                }
            }
        }
    }

    private func createTimer(time: Int, label: String, sound: SoundDisplay) {
        Task {
            let newOngoing = Timer(
                id: UUID(),
                milliseconds: time,
                isRunning: true,
                currentMilliseconds: time,
                sound: Sound(path: sound.path),
                label: label,
            )
            let newRecent = Timer(
                id: UUID(),
                milliseconds: time,
                isRunning: false,
                currentMilliseconds: time,
                sound: Sound(path: sound.path),
                label: label,
            )
            do {
                async let ongoingResult: Void = createTimerUseCase.execute(
                    timer: newOngoing,
                    isActive: true
                )
                async let recentResult: Void = createTimerUseCase.execute(
                    timer: newRecent,
                    isActive: false
                )
                _ = try await (ongoingResult, recentResult)

                let ongoingDisplay = TimerMapper.mapToDisplay(timer: newOngoing)
                updateSortedTimerDisplayRelay(with: ongoingTimer.value + [ongoingDisplay], to: ongoingTimer)

                let recentDisplay = TimerMapper.mapToDisplay(timer: newRecent)
                updateSortedTimerDisplayRelay(with: recentTimer.value + [recentDisplay], to: recentTimer)
            } catch {
                self.error.accept(error)
            }
        }
    }

    private func updateSortedTimerDisplayRelay(
        with displays: [TimerDisplay],
        to relay: BehaviorRelay<[TimerDisplay]>
    ) {
        let sorted = displays.sorted{ $0.remainingMillisecond < $1.remainingMillisecond }

        timerUpdateQueue.async {
            relay.accept(sorted)
        }
    }

    private func toggleOrAddTimer(with id: UUID) {
        // ongoingTimer에 존재한다면 토글, 없으면 RecentTimer를 ongoingTimer에 추가
        if let index = ongoingTimer.value.firstIndex(where: { $0.id == id }) {
            var timerDisplays = ongoingTimer.value
            var timerDisplay = timerDisplays[index]
            timerDisplay.toggleRunningState()
            timerDisplays[index] = timerDisplay

            updateSortedTimerDisplayRelay(with: timerDisplays, to: ongoingTimer)

            let timer = TimerMapper.mapToModel(display: timerDisplay)
            updateTimerInStorage(timer: timer)
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
        let timerDisplay = TimerMapper.mapToDisplay(timer: timer)
        let updatedOngoing = ongoingTimer.value + [timerDisplay]
        updateSortedTimerDisplayRelay(with: updatedOngoing, to: ongoingTimer)
        createTimerInStorage(timer: timer, isActive: true)
        return
    }

    private func deleteTimer(at indexPath: IndexPath) {
        switch TimerSectionType(rawValue: indexPath.section) {
        case .ongoingTimer:
            var timers = ongoingTimer.value
            let timer = timers.remove(at: indexPath.row)

            timerUpdateQueue.async {
                self.ongoingTimer.accept(timers)
            }

            deleteTimerFromStorage(id: timer.id)
        case .recentTimer:
            var timers = recentTimer.value
            let timer = timers.remove(at: indexPath.row)

            timerUpdateQueue.async {
                self.recentTimer.accept(timers)
            }

            deleteTimerFromStorage(id: timer.id)
        default:
            return
        }
    }

    private func createTimerInStorage(timer: Timer, isActive: Bool) {
        Task {
            do {
                try await createTimerUseCase.execute(timer: timer, isActive: isActive)
            } catch {
                self.error.accept(error)
            }
        }
    }

    private func updateTimerInStorage(timer: Timer) {
        Task {
            do {
                try await updateTimerUseCase.execute(timer: timer)
            } catch {
                self.error.accept(error)
            }
        }
    }

    private func deleteTimerFromStorage(id: UUID) {
        Task {
            do {
                try await deleteTimerUseCase.execute(by: id)
            } catch {
                self.error.accept(error)
            }
        }
    }
}
