//
//  FetchableAllTimerUseCase.swift
//  Clock
//
//  Created by 이수현 on 5/26/25.
//

import Foundation

protocol FetchableAllTimerUseCase {
    func execute() async throws -> (ongoing: [Timer], recent: [Timer])
}
