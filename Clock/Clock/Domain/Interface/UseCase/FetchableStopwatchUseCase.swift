//
//  FetchableStopwatchUseCase.swift
//  Clock
//
//  Created by 유현진 on 5/27/25.
//

import Foundation

protocol FetchableStopwatchUseCase {
    func execute() async throws -> Stopwatch
}
