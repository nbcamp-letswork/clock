import Foundation

final class DefaultAlarmNotificationRepository: AlarmNotificationRepository {
    private let service: AlarmNotificationService

    init(service: AlarmNotificationService) {
        self.service = service
    }

    func requestAuthorization() async throws -> Bool {
        try await service.requestAuthorization()
    }

    func schedule(_ notification: AlarmNotification) async throws {
        try await service.schedule(notification)
    }

    func cancel(id: UUID) async {
        await service.cancel(id: id)
    }

    func cancelAll(for alarmID: UUID) async {
        await service.cancelAll(alarmID)
    }
}
