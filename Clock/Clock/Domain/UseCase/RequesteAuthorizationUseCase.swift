final class RequesteAuthorizationUseCase: RequestableAuthorizationUseCase {
    private let alarmNotificationRepository: AlarmNotificationRepository

    init(alarmNotificationRepository: AlarmNotificationRepository) {
        self.alarmNotificationRepository = alarmNotificationRepository
    }

    func execute() async throws -> Bool {
        try await alarmNotificationRepository.requestAuthorization()
    }
}
