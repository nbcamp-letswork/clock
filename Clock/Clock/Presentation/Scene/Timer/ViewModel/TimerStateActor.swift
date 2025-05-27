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
    }

    func delete(at index: Int) -> TimerDisplay {
        timers.remove(at: index)
    }

    func set(_ timers: [TimerDisplay]) {
        self.timers = timers
    }

    func toggleRunnningState(at index: Int) {
        timers[index].toggleRunningState()
    }

    func getTimerIndex(with id: UUID) -> Int? {
        timers.firstIndex(where: { $0.id == id })
    }

    func getTimer(with id: UUID) -> TimerDisplay? {
        timers.first(where: {$0.id == id })
    }
}
