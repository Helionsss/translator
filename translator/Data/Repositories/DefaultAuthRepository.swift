import Foundation

final class DefaultAuthRepository: AuthRepository {
    private let validEmail: String
    private let validPassword: String
    private let sessionTokenKey = "auth.session.token"
    private let sessionUserIdKey = "auth.session.userId"

    init(validEmail: String = "test@example.com", validPassword: String = "Password123") {
        self.validEmail = validEmail
        self.validPassword = validPassword
    }

    func login(email: String, password: String) async throws -> UserSession {
        guard email.lowercased() == validEmail.lowercased(), password == validPassword else {
            throw AuthError.invalidCredentials
        }
        let session = UserSession(token: "local-token-123", userId: "user-1")
        let defaults = UserDefaults.standard
        defaults.set(session.token, forKey: sessionTokenKey)
        defaults.set(session.userId, forKey: sessionUserIdKey)
        return session
    }

    func restoreSession() async -> UserSession? {
        let defaults = UserDefaults.standard
        guard
            let token = defaults.string(forKey: sessionTokenKey),
            let userId = defaults.string(forKey: sessionUserIdKey)
        else {
            return nil
        }
        return UserSession(token: token, userId: userId)
    }
}
