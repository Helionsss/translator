final class DefaultAuthRepository: AuthRepository {
    func login(email: String, password: String) async throws -> UserSession {
        fatalError()
    }

    func restoreSession() async -> UserSession? {
        nil
    }
}
