import Foundation

protocol DeletableAlarmGroupUseCase {
    func execute(_ groupID: UUID) async throws
}
