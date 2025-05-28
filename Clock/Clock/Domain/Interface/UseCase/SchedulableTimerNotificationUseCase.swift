protocol SchedulableTimerNotificationUseCase {
    func execute(_ timer: Timer) async throws
}
