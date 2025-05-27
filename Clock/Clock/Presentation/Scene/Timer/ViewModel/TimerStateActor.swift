//
//  TimerStateActor.swift
//  Clock
//
//  Created by 이수현 on 5/27/25.
//

import Foundation

final actor TimerStateActor {
    private var timers: [TimerDisplay] = []

    func get() -> [TimerDisplay] {
        timers
    }

    func update(_ transform: ([TimerDisplay]) -> [TimerDisplay]) {
        timers = transform(timers)
            .sorted{ $0.remainingMillisecond < $1.remainingMillisecond }
    }

    func delete(at index: Int) -> TimerDisplay {
        timers.remove(at: index)
    }

    func set(_ timers: [TimerDisplay]) {
        self.timers = timers
            .sorted{ $0.remainingMillisecond < $1.remainingMillisecond }
    }

    func toggleRunnningState(at index: Int) {
        timers[index].toggleRunningState()
    }
}
