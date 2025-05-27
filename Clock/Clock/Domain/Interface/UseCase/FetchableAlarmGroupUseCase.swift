protocol FetchableAlarmGroupUseCase {
    func execute() async throws -> [AlarmGroup]
}
