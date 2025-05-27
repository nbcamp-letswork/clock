//
//  CreatableStopwatchUseCase.swift
//  Clock
//
//  Created by 유현진 on 5/27/25.
//

import Foundation

protocol CreatableStopwatchUseCase {
    func execute(stopwatch: Stopwatch) async throws -> Void
}
