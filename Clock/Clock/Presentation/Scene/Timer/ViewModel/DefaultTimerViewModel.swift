//
//  DefaultTimerViewModel.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit
import RxSwift
import RxCocoa

final class DefaultTimerViewModel: TimerViewModel {
    private let fetchRecentTimerUseCase: FetchableRecentTimerUseCase
    private let fetchOngoingTimerUseCase: FetchableOngoingTimerUseCase
    private let createTimerUseCase: CreatableTimerUseCase

    private let disposeBag = DisposeBag()

    // Input
    let viewDidLoad = PublishRelay<Void>()
    let createTimer = PublishRelay<(time: Int, label: String, sound: Sound)>()

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
    }

    private func fetchTimer() {
        Task {
            do {
                async let recentTimer = fetchRecentTimerUseCase.execute()
                async let ongoingTimer = fetchOngoingTimerUseCase.execute()

                self.recentTimer.accept(try await recentTimer.map{ TimerDisplay(timer: $0) })
                self.ongoingTimer.accept(try await ongoingTimer.map{ TimerDisplay(timer: $0) })
            } catch {
                self.error.accept(error)
            }
        }
    }

    private func createTimer(time: Int, label: String, sound: Sound) {
        Task {
            do {
                let timer = Timer(id: UUID(), milliseconds: time, currentMilliseconds: time, sound: sound, label: label)
                _ = try await createTimerUseCase.execute(timer: timer)
            } catch {
                self.error.accept(error)
            }
        }
    }
}
