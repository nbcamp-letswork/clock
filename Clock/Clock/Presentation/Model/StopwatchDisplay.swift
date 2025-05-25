//
//  StopwatchDisplay.swift
//  Clock
//
//  Created by 유현진 on 5/25/25.
//

import Foundation
enum LapType {
    case normal
    case longest
    case shortest
}

struct StopwatchDisplay: Hashable {
    let id: UUID
    let lapNumber: Int
    let lap: String
    let type: LapType
    
    static func == (lhs: StopwatchDisplay, rhs: StopwatchDisplay) -> Bool {
        return lhs.id == rhs.id
    }
}
