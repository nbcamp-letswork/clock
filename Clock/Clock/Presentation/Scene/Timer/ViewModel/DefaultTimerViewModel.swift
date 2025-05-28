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
    private let scheduleTimerNotificationUseCase: SchedulableTimerNotificationUseCase
    private let cancelTimerNotificationUseCase: CancelableTimerNotificationUseCase

    private let ongoingTimerActor = TimerStateActor()
    private let recentTimerActor = TimerStateActor()

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
        updateTimerUseCase: UpdatableTimerUseCase,
        scheduleTimerNotificationUseCase: SchedulableTimerNotificationUseCase,
        cancelTimerNotificationUseCase: CancelableTimerNotificationUseCase
    ) {
        self.fetchAllTimerUseCase = fetchAllTimerUseCase
        self.createTimerUseCase = createTimerUseCase
        self.deleteTimerUseCase = deleteTimerUseCase
        self.updateTimerUseCase = updateTimerUseCase
        self.scheduleTimerNotificationUseCase = scheduleTimerNotificationUseCase
        self.cancelTimerNotificationUseCase = cancelTimerNotificationUseCase
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
        Task {
            var finishedTimer: TimerDisplay?

            await ongoingTimerActor.update { timers in
                var updatedTimers = timers
                for (index, timer) in timers.enumerated() where timer.isRunning {
                    var updated = timer
                    updated.reduceRemaining()
                    updatedTimers[index] = updated
                    if updated.remainingMillisecond == 0 {
                        let timer = updatedTimers.remove(at: index)
                        deleteTimerFromStorage(id: timer.id)
                        finishedTimer = timer
                        break
                    }
                }
                return updatedTimers
            }

            if let finishedTimer {
                await self.cancelTimerNotificationUseCase.execute(by: finishedTimer.id)
            }

            ongoingTimer.accept(await ongoingTimerActor.get())
        }
    }

    private func fetchTimers() {
        Task {
            do {
                let (ongoing, recent) = try await fetchAllTimerUseCase.execute()
                let ongoingTimerDisplay = ongoing.map{ TimerMapper.mapToDisplay(timer: $0) }
                    .sorted{ $0.remainingMillisecond < $1.remainingMillisecond }
                let recentTimerDisplay = recent.map{ TimerMapper.mapToDisplay(timer: $0) }
                    .sorted{ $0.remainingMillisecond < $1.remainingMillisecond }
                await ongoingTimerActor.set(ongoingTimerDisplay)
                await recentTimerActor.set(recentTimerDisplay)

                ongoingTimer.accept(await ongoingTimerActor.get())
                recentTimer.accept(await recentTimerActor.get())

                for timerModel in ongoing where timerModel.isRunning {
                    await self.cancelTimerNotificationUseCase.execute(by: timerModel.id)
                    try? await self.scheduleTimerNotificationUseCase.execute(timerModel)
                }
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
                await ongoingTimerActor.update { timers in
                    return timers + [ongoingDisplay]
                }
                ongoingTimer.accept(await ongoingTimerActor.get())


                let recentDisplay = TimerMapper.mapToDisplay(timer: newRecent)
                await recentTimerActor.update { timers in
                    return timers + [recentDisplay]
                }
                recentTimer.accept(await recentTimerActor.get())

                try await self.scheduleTimerNotificationUseCase.execute(newOngoing)
            } catch {
                self.error.accept(error)
            }
        }
    }

    private func toggleOrAddTimer(with id: UUID) {
        Task {
            // ongoingTimer에 존재한다면 토글, 없으면 RecentTimer를 ongoingTimer에 추가
            if let index = await ongoingTimerActor.getTimerIndex(with: id) {
                await ongoingTimerActor.toggleRunnningState(at: index)
                ongoingTimer.accept(await ongoingTimerActor.get())

                let timer = TimerMapper.mapToModel(display: await ongoingTimerActor.get()[index])
                updateTimerInStorage(timer: timer)

                if timer.isRunning {
                    await self.cancelTimerNotificationUseCase.execute(by: timer.id)
                    try? await self.scheduleTimerNotificationUseCase.execute(timer)
                } else {
                    await self.cancelTimerNotificationUseCase.execute(by: timer.id)
                }

                return
            }

            guard let recent = await recentTimerActor.getTimer(with: id) else {
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
            await ongoingTimerActor.update { timers in
                return timers + [timerDisplay]
            }

            ongoingTimer.accept(await ongoingTimerActor.get())
            createTimerInStorage(timer: timer, isActive: true)

            Task {
                try await self.scheduleTimerNotificationUseCase.execute(timer)
            }
        }
    }

    private func deleteTimer(at indexPath: IndexPath) {
        Task {
            switch TimerSectionType(rawValue: indexPath.section) {
            case .ongoingTimer:
                let deletedTimer = await ongoingTimerActor.delete(at: indexPath.row)
                ongoingTimer.accept(await ongoingTimerActor.get())
                deleteTimerFromStorage(id: deletedTimer.id)
                await cancelTimerNotificationUseCase.execute(by: deletedTimer.id)
            case .recentTimer:
                let deletedTimer = await recentTimerActor.delete(at: indexPath.row)
                recentTimer.accept(await recentTimerActor.get())
                deleteTimerFromStorage(id: deletedTimer.id)
                await cancelTimerNotificationUseCase.execute(by: deletedTimer.id)
            default:
                return
            }
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
