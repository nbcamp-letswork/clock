import Foundation

protocol DeletableAlarmUseCase {
    func execute(_ alarmID: UUID) async throws
}
