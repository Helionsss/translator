import Foundation

final class DefaultLoginUseCase: LoginUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(_ request: LoginRequest) async throws -> UserSession {
        return try await repository.login(email: request.email, password: request.password)
    }
}
