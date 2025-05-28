import Foundation

final class ScheduleTimerNotificationUseCase: SchedulableTimerNotificationUseCase {
    private let timerNotificationService: TimerNotificationService

    init(timerNotificationService: TimerNotificationService) {
        self.timerNotificationService = timerNotificationService
    }

    func execute(_ timer: Timer) async throws {
        let date = Date().addingTimeInterval(Double(timer.currentMilliseconds) / 1000.0)

        let timerNotification = TimerNotification(
            id: timer.id,
            title: "타이머",
            body: timer.label,
            sound: timer.sound.path,
            categoryIdentifier: "timerCompletion",
            date: date
        )

        try await timerNotificationService.schedule(timerNotification)
    }
}
