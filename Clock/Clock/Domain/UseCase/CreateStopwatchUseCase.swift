//
//  CreateStopwatchUseCase.swift
//  Clock
//
//  Created by 유현진 on 5/27/25.
//

import Foundation

final class CreateStopwatchUseCase: CreatableStopwatchUseCase {
    private let repository: StopwatchRepository
    
    init(repository: StopwatchRepository) {
        self.repository = repository
    }
    
    func execute(stopwatch: Stopwatch) async throws -> Void {
        try await repository.save(stopwatch).get()
    }
}
