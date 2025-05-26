//
//  UpdateTimerUseCase.swift
//  Clock
//
//  Created by 이수현 on 5/26/25.
//

import Foundation

final class UpdateTimerUseCase: UpdatableTimerUseCase {
    private let repository: TimerRepository

    init(repository: TimerRepository) {
        self.repository = repository
    }

    func execute(timer: Timer) async throws {
        try await repository.update(timer).get()
    }
}
