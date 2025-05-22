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
    private let disposeBag = DisposeBag()

    // Input
    let viewDidLoad = PublishRelay<Void>()

    // Output
    let recentTimer = BehaviorRelay<[Timer]>(value: [])
    let ongoingTimer = BehaviorRelay<[Timer]>(value: [])
    let error = PublishRelay<Error>()

    init(fetchRecentTimerUseCase: FetchableRecentTimerUseCase) {
        self.fetchRecentTimerUseCase = fetchRecentTimerUseCase
        bindInput()
    }

    private func bindInput() {
        viewDidLoad.bind {[weak self] _ in
            self?.fetchTimer()
        }.disposed(by: disposeBag)
    }

    private func fetchTimer() {
        Task {
            do {
                async let recentTimer = fetchRecentTimerUseCase.execute()
                async let ongoingTimer = fetchRecentTimerUseCase.execute()

                self.recentTimer.accept(try await recentTimer)
                self.ongoingTimer.accept(try await ongoingTimer)
            } catch {
                self.error.accept(error)
            }
        }
    }
}
