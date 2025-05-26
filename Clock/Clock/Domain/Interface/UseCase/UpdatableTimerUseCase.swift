//
//  UpdatableTimerUseCase.swift
//  Clock
//
//  Created by 이수현 on 5/26/25.
//

import Foundation

protocol UpdatableTimerUseCase {
    func execute(timer: Timer) async throws -> Void
}
