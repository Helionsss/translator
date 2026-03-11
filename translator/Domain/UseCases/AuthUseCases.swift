struct LoginRequest: Equatable {
    let email: String
    let password: String
}

protocol LoginUseCase {
    func execute(_ request: LoginRequest) async throws -> UserSession
}

protocol RestoreSessionUseCase {
    func execute() async -> UserSession?
}
