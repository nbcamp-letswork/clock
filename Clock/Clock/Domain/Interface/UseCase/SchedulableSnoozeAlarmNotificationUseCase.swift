import Foundation

protocol SchedulableSnoozeAlarmNotificationUseCase {
    func execute(_ alarmID: UUID, duration: TimeInterval) async throws
}
