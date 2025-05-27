import Foundation
import UserNotifications

protocol AlarmNotificationService {
    func requestAuthorization() async throws -> Bool
    func schedule(_ notification: AlarmNotification) async throws
    func cancel(id: UUID) async
    func cancelAll(_ alarmID: UUID) async
    func fetch(from userInfo: [AnyHashable: Any]) -> AlarmNotification?
}
