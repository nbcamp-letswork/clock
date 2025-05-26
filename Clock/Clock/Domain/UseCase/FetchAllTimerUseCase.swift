//
//  FetchAllTimerUseCase.swift
//  Clock
//
//  Created by 이수현 on 5/26/25.
//

import Foundation

final class FetchAllTimerUseCase: FetchableAllTimerUseCase {
    private let repository: TimerRepository

    init(repository: TimerRepository) {
        self.repository = repository
    }

    func execute() async throws -> (ongoing: [Timer], recent: [Timer]) {
        try await repository.fetchAll().get()
    }
}
