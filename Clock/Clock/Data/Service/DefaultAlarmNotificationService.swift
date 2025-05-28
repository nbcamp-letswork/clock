import UserNotifications

final class DefaultAlarmNotificationService: AlarmNotificationService {
    private let notificationCenter = UNUserNotificationCenter.current()

    func requestAuthorization() async throws -> Bool {
        return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func schedule(_ notification: AlarmNotification) async throws {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body

        if notification.sound.isEmpty {
            content.sound = .default
        } else {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(notification.sound))
        }

        content.categoryIdentifier = notification.categoryIdentifier

        if let encodedData = try? encodeAlarmNotification(notification) {
            content.userInfo["alarm_notification_data"] = encodedData.base64EncodedString()
        }

        let trigger: UNNotificationTrigger
        switch notification.triggerType {
        case .dateComponents(let dateComponents, let repeats):
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        case .timeInterval(let timeInterval, let repeats):
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: repeats)
        }

        let request = UNNotificationRequest(identifier: notification.id.uuidString, content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
        } catch {}
    }

    func cancel(id: UUID) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }

    func cancelAll(_ alarmID: UUID) async {
        let pendingRequests = await notificationCenter.pendingNotificationRequests()
        let requestsToCancel = pendingRequests.filter { request in
            if let base64EncodedDataString = request.content.userInfo["alarm_notification_data"] as? String,
               let encodedData = Data(base64Encoded: base64EncodedDataString),
               let alarmNotification = try? decodeAlarmNotification(from: encodedData) {
                return alarmNotification.alarmID == alarmID
            }
            return false
        }.map { $0.identifier }

        if !requestsToCancel.isEmpty {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: requestsToCancel)
        }
    }

    func fetch(from userInfo: [AnyHashable: Any]) -> AlarmNotification? {
        if let base64EncodedDataString = userInfo["alarm_notification_data"] as? String,
           let encodedData = Data(base64Encoded: base64EncodedDataString),
           let alarmNotification = try? decodeAlarmNotification(from: encodedData) {
            return alarmNotification
        }

        return nil
    }

    private func encodeAlarmNotification(_ notification: AlarmNotification) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(notification)
    }

    private func decodeAlarmNotification(from data: Data) throws -> AlarmNotification {
        let decoder = JSONDecoder()
        return try decoder.decode(AlarmNotification.self, from: data)
    }

}
