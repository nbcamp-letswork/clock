import Foundation

protocol UpdatableAlarmUseCase {
    func execute(_ alarm: Alarm, _ group: AlarmGroup) async throws
    func execute(_ alarm: Alarm) async throws
    func execute(_ id: UUID) async throws
}
