import Foundation

struct AlarmNotification: Codable {
    let id: UUID
    let alarmID: UUID
    let isSnooze: Bool
    let title: String
    let body: String
    let sound: String
    let categoryIdentifier: String
    let triggerType: AlarmNotificationTriggerType
}

enum AlarmNotificationTriggerType: Codable {
    case dateComponents(DateComponents, repeats: Bool)
    case timeInterval(TimeInterval, repeats: Bool)
}
