//
//  CreatableTimerUseCase.swift
//  Clock
//
//  Created by 이수현 on 5/22/25.
//

import Foundation

protocol CreatableTimerUseCase {
    func execute(timer: Timer) async throws -> Void
}
