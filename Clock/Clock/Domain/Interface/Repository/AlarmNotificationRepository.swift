import Foundation

protocol AlarmNotificationRepository {
    func requestAuthorization() async throws -> Bool
    func schedule(_ notification: AlarmNotification) async throws
    func cancel(id: UUID) async
    func cancelAll(for alarmID: UUID) async
}
