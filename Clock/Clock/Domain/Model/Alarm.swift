import Foundation

struct AlarmGroup {
    let id: UUID
    let name: String
    let order: Int
    let alarms: [Alarm]
}

struct Alarm {
    let id: UUID
    let hour: Int
    let minute: Int
    let label: String
    let sound: Sound
    let isSnooze: Bool
    let isEnabled: Bool
    let repeatDays: [RepeatDay]
}

struct RepeatDay {
    let weekday: Int
}
