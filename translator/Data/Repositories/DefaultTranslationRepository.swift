final class DefaultTranslationRepository: TranslationRepository {
    func translateRemote(_ request: TranslateRequest) async throws -> Translation {
        fatalError()
    }

    func translateLocal(_ request: TranslateRequest) async throws -> Translation {
        fatalError()
    }
}
