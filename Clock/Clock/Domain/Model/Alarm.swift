import Foundation

struct AlarmGroup {
    let id: UUID
    var name: String
    var order: Int
    var alarms: [Alarm]
}

struct Alarm {
    let id: UUID
    let hour: Int
    let minute: Int
    let label: String
    let sound: Sound
    let isSnooze: Bool
    var isEnabled: Bool
    let repeatDays: [RepeatDay]
}

struct RepeatDay {
    let weekday: Int
}
