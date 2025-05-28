final class FetchAlarmGroupUseCase: FetchableAlarmGroupUseCase {
    private let alarmGroupRepository: AlarmGroupRepository

    init(alarmGroupRepository: AlarmGroupRepository) {
        self.alarmGroupRepository = alarmGroupRepository
    }

    func execute() async throws -> [AlarmGroup] {
        try await alarmGroupRepository.fetchAll().get()
    }
}
