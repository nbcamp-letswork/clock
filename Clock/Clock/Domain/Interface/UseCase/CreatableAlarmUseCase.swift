protocol CreatableAlarmUseCase {
    func execute(_ alarm: Alarm, into alarmGroup: AlarmGroup) async throws
}
