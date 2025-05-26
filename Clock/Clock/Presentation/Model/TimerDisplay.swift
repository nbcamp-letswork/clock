//
//  TimerDisplay.swift
//  Clock
//
//  Created by 이수현 on 5/22/25.
//

import Foundation

struct TimerDisplay {
    let id: UUID
    let label: String
    var remainingMillisecond: Int
    var remainingTimeString: String
    var isRunning: Bool
    let sound: Sound

    mutating func reduceRemaining() {
        guard isRunning else { return }
        remainingMillisecond = max(0, remainingMillisecond - 1000)
        remainingTimeString = TimerDisplayFormatter.formatToDigitalTime(millisecond: remainingMillisecond)
    }

    mutating func toggleRunningState() {
        isRunning.toggle()
    }
}

enum TimerDisplayFormatter {
    static func formatToKoreanTimeString(millisecond: Int) -> String {
        let (hour, minute, second) = millisecondToTime(millisecond: millisecond)
        var timeString = ""

        if hour != 0 { timeString += "\(hour)시간 "}
        if minute != 0 { timeString += "\(minute)분 "}
        if second != 0 { timeString += "\(second)초"}

        return timeString.trimmingCharacters(in: .whitespaces)
    }

    static func formatToDigitalTime(millisecond: Int) -> String {
        let (hour, minute, second) = millisecondToTime(millisecond: millisecond)

        if hour > 0 {
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        } else {
            return String(format: "%02d:%02d", minute, second)
        }
    }

    static func millisecondToTime(millisecond: Int) -> (hour: Int, minute: Int, second: Int) {
        let totalSecond = millisecond / 1000
        let hour = totalSecond / (60 * 60)
        let minute = totalSecond % (60 * 60) / 60
        let second = totalSecond % 60
        return (hour, minute, second)
    }
}
