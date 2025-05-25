import Foundation

final class DeleteAlarmUseCase: DeletableAlarmUseCase {
    private let alarmRepository: AlarmRepository

    init(alarmRepository: AlarmRepository) {
        self.alarmRepository = alarmRepository
    }

    func execute(_ alarmID: UUID) async throws {
        try await alarmRepository.delete(by: alarmID).get()
    }
}
