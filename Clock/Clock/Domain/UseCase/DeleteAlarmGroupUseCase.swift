import Foundation

final class DeleteAlarmGroupUseCase: DeletableAlarmGroupUseCase {
    private let alarmGroupRepository: AlarmGroupRepository

    init(alarmGroupRepository: AlarmGroupRepository) {
        self.alarmGroupRepository = alarmGroupRepository
    }

    func execute(_ groupID: UUID) async throws {
        try await alarmGroupRepository.delete(by: groupID).get()
    }
}
