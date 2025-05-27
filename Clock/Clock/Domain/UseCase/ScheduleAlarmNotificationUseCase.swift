import Foundation

final class ScheduleAlarmNotificationUseCase: SchedulableAlarmNotificationUseCase {
    private let alarmNotificationRepository: AlarmNotificationRepository

    init(alarmNotificationRepository: AlarmNotificationRepository) {
        self.alarmNotificationRepository = alarmNotificationRepository
    }

    func execute(_ alarm: Alarm) async throws {
        await alarmNotificationRepository.cancelAll(for: alarm.id)

        guard alarm.isEnabled else {
            return
        }

        if alarm.isEnabled {
            if alarm.repeatDays.isEmpty {
                var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
                dateComponents.hour = alarm.hour
                dateComponents.minute = alarm.minute

                let notification = AlarmNotification(
                    id: UUID(),
                    alarmID: alarm.id,
                    isSnooze: alarm.isSnooze,
                    title: alarm.label.isEmpty ? "알람" : alarm.label,
                    body: "\(alarm.hour):\(alarm.minute)",
                    sound: alarm.sound.path,
                    categoryIdentifier: "alarmCategory",
                    triggerType: .dateComponents(dateComponents, repeats: false)
                )
                try await alarmNotificationRepository.schedule(notification)

            } else {
                for day in alarm.repeatDays {
                    var dateComponents = DateComponents()
                    dateComponents.hour = alarm.hour
                    dateComponents.minute = alarm.minute
                    dateComponents.weekday = day.weekday

                    let notification = AlarmNotification(
                        id: UUID(),
                        alarmID: alarm.id,
                        isSnooze: alarm.isSnooze,
                        title: alarm.label.isEmpty ? "알람" : alarm.label,
                        body: "\(alarm.hour):\(alarm.minute)",
                        sound: alarm.sound.path,
                        categoryIdentifier: "alarmCategory",
                        triggerType: .dateComponents(dateComponents, repeats: true)
                    )
                    try await alarmNotificationRepository.schedule(notification)
                }
            }
        }
    }
}
