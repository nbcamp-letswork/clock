//
//  Stopwatch.swift
//  Clock
//
//  Created by youseokhwan on 5/26/25.
//

import Foundation

struct Stopwatch {
    let isRunning: Bool
    let laps: [Lap]
}

struct Lap {
    let lapNumber: Int
    let time: Double
}
