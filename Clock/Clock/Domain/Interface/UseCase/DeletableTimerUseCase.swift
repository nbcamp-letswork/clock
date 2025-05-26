//
//  DeletableTimerUseCase.swift
//  Clock
//
//  Created by 이수현 on 5/26/25.
//

import Foundation

protocol DeletableTimerUseCase {
    func execute(by id: UUID) async throws -> Void
}
