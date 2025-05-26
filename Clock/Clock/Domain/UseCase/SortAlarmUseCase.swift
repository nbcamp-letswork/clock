final class SortAlarmUseCase: SortableAlarmUseCase {
    func execute(_ groups: [AlarmGroup]) -> [AlarmGroup] {
        groups
            .sorted { $0.order < $1.order }
            .map { group in
                AlarmGroup(
                    id: group.id,
                    name: group.name,
                    order: group.order,
                    alarms: group.alarms.sorted {
                        ($0.hour, $0.minute) < ($1.hour, $1.minute)
                    }
                )
            }
    }
}
