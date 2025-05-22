//
//  FetchableOngoingTimerUseCase.swift
//  Clock
//
//  Created by 이수현 on 5/22/25.
//

import Foundation

protocol FetchableOngoingTimerUseCase {
    func execute() async throws -> [Timer]
}

