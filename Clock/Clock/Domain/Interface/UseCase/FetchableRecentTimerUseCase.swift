//
//  FetchableRecentTimerUseCase.swift
//  Clock
//
//  Created by 이수현 on 5/22/25.
//

import Foundation

protocol FetchableRecentTimerUseCase {
    func execute() async throws -> [Timer]
}
