//
//  DeleteStopwatchUseCase.swift
//  Clock
//
//  Created by 유현진 on 5/27/25.
//

import Foundation

final class DeleteStopwatchUseCase: DeletableStopwatchUseCase {
    private let repository: StopwatchRepository
    
    init(repository: StopwatchRepository) {
        self.repository = repository
    }
    
    func execute() async throws {
        try await repository.delete().get()
    }
}
