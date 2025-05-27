protocol RequestableAuthorizationUseCase {
    func execute() async throws -> Bool
}
