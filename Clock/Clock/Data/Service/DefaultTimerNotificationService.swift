import UserNotifications

final class DefaultTimerNotificationService: TimerNotificationService {
    private let notificationCenter = UNUserNotificationCenter.current()

    func schedule(_ notification: TimerNotification) async throws {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body

        if notification.sound.isEmpty {
            content.sound = .default
        } else {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(notification.sound))
        }

        content.categoryIdentifier = notification.categoryIdentifier

        if let encodedData = try? encodeTimerNotification(notification) {
            content.userInfo["timer_notification_data"] = encodedData.base64EncodedString()
        } else {}

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notification.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: notification.id.uuidString, content: content, trigger: trigger)


        do {
            try await notificationCenter.add(request)
        } catch {}
    }

    func cancel(id: UUID) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }

    private func encodeTimerNotification(_ notification: TimerNotification) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        return try encoder.encode(notification)
    }

    private func decodeTimerNotification(from data: Data) throws -> TimerNotification {
        let decoder = JSONDecoder()

        return try decoder.decode(TimerNotification.self, from: data)
    }
}
