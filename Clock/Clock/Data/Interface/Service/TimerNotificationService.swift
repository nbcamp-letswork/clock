import Foundation
import UserNotifications

protocol TimerNotificationService {
    func schedule(_ notification: TimerNotification) async throws
    func cancel(id: UUID) async
}
