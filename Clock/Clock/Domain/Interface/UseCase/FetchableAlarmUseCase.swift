protocol FetchableAlarmUseCase {
    func execute() async throws -> [AlarmGroup]
}
