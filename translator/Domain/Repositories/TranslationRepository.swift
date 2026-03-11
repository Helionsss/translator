protocol TranslationRepository {
    func translateRemote(_ request: TranslateRequest) async throws -> Translation
    func translateLocal(_ request: TranslateRequest) async throws -> Translation
}
