protocol SchedulableAlarmNotificationUseCase {
    func execute(_ alarm: Alarm) async throws
}
