import Foundation

final class CancelAlarmNotificationUseCase: CancelableAlarmNotificationUseCase {
    private let alarmNotificationRepository: AlarmNotificationRepository

    init(alarmNotificationRepository: AlarmNotificationRepository) {
        self.alarmNotificationRepository = alarmNotificationRepository
    }

    func execute(_ alarmID: UUID) async {
        await alarmNotificationRepository.cancelAll(for: alarmID)
    }
}
