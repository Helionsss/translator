protocol AuthRepository {
    func login(email: String, password: String) async throws -> UserSession
    func restoreSession() async -> UserSession?
}
