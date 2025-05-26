import Foundation

protocol UpdatableAlarmUseCase {
    func execute(_ alarm: Alarm) async throws
}
