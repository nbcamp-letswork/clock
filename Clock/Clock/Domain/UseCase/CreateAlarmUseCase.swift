final class CreateAlarmUseCase: CreatableAlarmUseCase {
    private let alarmGroupRepository: AlarmGroupRepository
    private let alarmRepository: AlarmRepository

    init(alarmGroupRepository: AlarmGroupRepository, alarmRepository: AlarmRepository) {
        self.alarmGroupRepository = alarmGroupRepository
        self.alarmRepository = alarmRepository
    }

    func execute(_ alarm: Alarm, into alarmGroup: AlarmGroup) async throws {
        let exists = try await alarmGroupRepository.exists(by: alarmGroup.id).get()

        if !exists {
            try await alarmGroupRepository.create(alarmGroup).get()
        }

        try await alarmRepository.create(alarm, into: alarmGroup.id).get()
    }
}
