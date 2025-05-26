protocol SortableAlarmUseCase {
    func execute(_ alarmGroup: [AlarmGroup]) -> [AlarmGroup]
}
