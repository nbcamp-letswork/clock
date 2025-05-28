
import Foundation

protocol CancelableTimerNotificationUseCase {
    func execute(by id: UUID) async
}
