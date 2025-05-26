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

struct StopwatchDisplay {
    let lapNumber: Int
    let lap: String
    let type: LapType
}
