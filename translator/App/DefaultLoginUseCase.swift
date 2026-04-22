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

actor TranslationStore {
    private var items: [Translation] = []

    func append(_ translation: Translation) {
        items.append(translation)
    }

    func all() -> [Translation] {
        items
    }
}

final class DefaultTranslateUseCase: TranslateUseCase {
    func execute(_ request: TranslateRequest) async throws -> Translation {
        let translated = "\(String(request.text.reversed())) [\(request.target.code.uppercased())]"
        return Translation(
            id: UUID(),
            original: request.text,
            translated: translated,
            source: request.source,
            target: request.target,
            createdAt: Date()
        )
    }
}

final class DefaultSaveTranslationUseCase: SaveTranslationUseCase {
    private let store: TranslationStore

    init(store: TranslationStore) {
        self.store = store
    }

    func execute(_ translation: Translation) async throws {
        await store.append(translation)
    }
}

final class DefaultGetHistoryUseCase: GetHistoryUseCase {
    private let store: TranslationStore

    init(store: TranslationStore) {
        self.store = store
    }

    func execute() async throws -> [Translation] {
        await store.all()
    }
}
