import Foundation

final class ScheduleSnoozeAlarmNotificationUseCase: SchedulableSnoozeAlarmNotificationUseCase {
    private let alarmNotificationRepository: AlarmNotificationRepository
    private let alarmRepository: AlarmRepository

    init(alarmNotificationRepository: AlarmNotificationRepository, alarmRepository: AlarmRepository) {
        self.alarmNotificationRepository = alarmNotificationRepository
        self.alarmRepository = alarmRepository
    }

    func execute(_ alarmID: UUID, duration: TimeInterval) async throws {
        let alarm = try await alarmRepository.fetch(alarmID).get()

        let snoozeNotification = AlarmNotification(
            id: UUID(),
            alarmID: alarmID,
            isSnooze: true,
            title: alarm.label,
            body: "\(alarm.hour):\(alarm.minute)",
            sound: alarm.sound.path,
            categoryIdentifier: "alarmCategory",
            triggerType: .timeInterval(duration, repeats: false)
        )

        try await alarmNotificationRepository.schedule(snoozeNotification)
    }
}
