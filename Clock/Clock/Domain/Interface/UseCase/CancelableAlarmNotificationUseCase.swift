import Foundation

protocol CancelableAlarmNotificationUseCase {
    func execute(_ alarmID: UUID) async
}
