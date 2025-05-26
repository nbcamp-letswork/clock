//
//  TimerMapper.swift
//  Clock
//
//  Created by 이수현 on 5/26/25.
//

import Foundation

enum TimerMapper {
    static func mapToDisplay(timer: Timer) -> TimerDisplay {
        let label = timer.label.isEmpty ? TimerDisplayFormatter.formatToKoreanTimeString(
            millisecond: timer.milliseconds
        ) : timer.label

        return TimerDisplay(
            id: timer.id,
            label: label,
            millisecond: timer.milliseconds,
            remainingMillisecond: timer.currentMilliseconds,
            remainingTimeString: TimerDisplayFormatter.formatToDigitalTime(
                millisecond: timer.currentMilliseconds
            ),
            isRunning: timer.isRunning,
            sound: timer.sound
        )
    }

    static func mapToModel(display: TimerDisplay) -> Timer {
        Timer(
            id: display.id,
            milliseconds: display.millisecond,
            isRunning: display.isRunning,
            currentMilliseconds: display.remainingMillisecond,
            sound: display.sound,
            label: display.label
        )
    }
}
