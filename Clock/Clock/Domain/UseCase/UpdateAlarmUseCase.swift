final class UpdateAlarmUseCase: UpdatableAlarmUseCase {
    private let alarmRepository: AlarmRepository
    private let alarmGroupRepository: AlarmGroupRepository

    init(alarmRepository: AlarmRepository, alarmGroupRepository: AlarmGroupRepository) {
        self.alarmRepository = alarmRepository
        self.alarmGroupRepository = alarmGroupRepository
    }

    func execute(_ newAlarm: Alarm, _ newGroup: AlarmGroup) async throws {
        let groups = try await alarmGroupRepository.fetchAll().get()

        var foundOriginalGroup: AlarmGroup?

        for group in groups {
            if let _ = group.alarms.first(where: { $0.id == newAlarm.id }) {
                foundOriginalGroup = group

                break
            }
        }

        guard let originalGroup = foundOriginalGroup else { return }

        let originalGroupID = originalGroup.id
        let newGroupID = newGroup.id

        var existingGroup: AlarmGroup

        let foundNewGroup = groups.first(where: { $0.id == newGroupID })

        if let foundNewGroup {
            existingGroup = foundNewGroup
            existingGroup.name = newGroup.name
            existingGroup.order = newGroup.order

            try await alarmGroupRepository.update(existingGroup).get()
        } else {
            existingGroup = newGroup
            existingGroup.alarms = []

            try await alarmGroupRepository.create(existingGroup).get()
        }

        if originalGroupID != newGroupID {
            var updatedOriginalGroup = originalGroup
            updatedOriginalGroup.alarms.removeAll { $0.id == newAlarm.id }

            if updatedOriginalGroup.alarms.isEmpty {
                try await alarmGroupRepository.delete(by: originalGroupID).get()
            } else {
                try await alarmRepository.delete(by: newAlarm.id).get()
            }

            if !existingGroup.alarms.contains(where: { $0.id == newAlarm.id }) {
                try await alarmRepository.create(newAlarm, into: existingGroup.id).get()
            }
        } else {
            try await execute(newAlarm)
        }
    }

    func execute(_ alarm: Alarm) async throws {
        try await alarmRepository.update(alarm).get()
    }
}
