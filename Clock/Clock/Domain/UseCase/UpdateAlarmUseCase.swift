final class UpdateAlarmUseCase: UpdatableAlarmUseCase {
    private let alarmRepository: AlarmRepository

    init(alarmRepository: AlarmRepository) {
        self.alarmRepository = alarmRepository
    }

    func execute(_ alarm: Alarm) async throws {
        try await alarmRepository.update(alarm).get()
    }
}
