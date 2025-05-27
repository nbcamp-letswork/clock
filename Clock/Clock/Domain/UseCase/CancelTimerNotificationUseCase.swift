import Foundation

final class CancelTimerNotificationUseCase: CancelableTimerNotificationUseCase {
    private let timerNotificationService: TimerNotificationService

    init(timerNotificationService: TimerNotificationService) {
        self.timerNotificationService = timerNotificationService
    }

    func execute(by id: UUID) async {
        await timerNotificationService.cancel(id: id)
    }
}
