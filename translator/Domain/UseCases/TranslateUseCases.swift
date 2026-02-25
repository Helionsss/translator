enum TranslationStyle: Equatable {
    case formal
    case informal
    case technical
}

enum TranslationMode: Equatable {
    case online
    case offline
    case auto
}

struct TranslateRequest: Equatable {
    let text: String
    let source: Language
    let target: Language
    let style: TranslationStyle
    let mode: TranslationMode
}

protocol TranslateUseCase {
    func execute(_ request: TranslateRequest) async throws -> Translation
}

protocol SaveTranslationUseCase {
    func execute(_ translation: Translation) async throws
}

protocol GetHistoryUseCase {
    func execute() async throws -> [Translation]
}
