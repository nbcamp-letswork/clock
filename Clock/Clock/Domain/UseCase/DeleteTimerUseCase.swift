//
//  DeleteTimerUseCase.swift
//  Clock
//
//  Created by 이수현 on 5/26/25.
//

import Foundation

final class DeleteTimerUseCase: DeletableTimerUseCase {
    private let repository: TimerRepository

    init(repository: TimerRepository) {
        self.repository = repository
    }

    func execute(by id: UUID) async throws {
        try await repository.delete(by: id).get()
    }
}
