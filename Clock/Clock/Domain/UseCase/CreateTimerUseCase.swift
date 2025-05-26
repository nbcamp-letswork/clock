//
//  CreateTimerUseCAse.swift
//  Clock
//
//  Created by 이수현 on 5/22/25.
//

import Foundation

final class CreateTimerUseCase: CreatableTimerUseCase {
    private let repository: TimerRepository

    init(repository: TimerRepository) {
        self.repository = repository
    }

    func execute(timer: Timer, isActive: Bool) async throws -> Void {
        try await repository.create(timer, isActive: isActive).get()
    }
}
