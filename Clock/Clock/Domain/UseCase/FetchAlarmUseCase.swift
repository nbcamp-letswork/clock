final class FetchAlarmUseCase: FetchableAlarmUseCase {
    private let alarmGroupRepository: AlarmGroupRepository

    init(alarmGroupRepository: AlarmGroupRepository) {
        self.alarmGroupRepository = alarmGroupRepository
    }

    func execute() async throws -> [AlarmGroup] {
        let result = await alarmGroupRepository.fetchAll()

        return try sort(result.get())
    }

    private func sort(_ groups: [AlarmGroup]) -> [AlarmGroup] {
        groups.map { group in
            let sortedAlarms = group.alarms
                .map { alarm in
                    let sortedRepeatDays = alarm.repeatDays.sorted { $0.weekday < $1.weekday }

                    return Alarm(
                        id: alarm.id,
                        hour: alarm.hour,
                        minute: alarm.minute,
                        label: alarm.label,
                        sound: alarm.sound,
                        isSnooze: alarm.isSnooze,
                        isEnabled: alarm.isEnabled,
                        repeatDays: sortedRepeatDays
                    )
                }
                .sorted { ($0.hour, $0.minute) < ($1.hour, $1.minute) }

            return AlarmGroup(
                id: group.id,
                name: group.name,
                order: group.order,
                alarms: sortedAlarms
            )
        }
        .sorted { $0.order < $1.order }
    }
}
