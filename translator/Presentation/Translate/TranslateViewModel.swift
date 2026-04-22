import Foundation

final class DefaultTranslateViewModel: TranslateViewModel, AppLifecycleListener {
    weak var view: TranslateView?

    private let translateUseCase: TranslateUseCase
    private let saveUseCase: SaveTranslationUseCase
    private let historyUseCase: GetHistoryUseCase

    private let sourceLanguage = Language(code: "en", displayName: "English")
    private let targetLanguage = Language(code: "ru", displayName: "Russian")

    private var task: Task<Void, Never>?
    private var lastTranslation: Translation?

    init(
        translateUseCase: TranslateUseCase,
        saveUseCase: SaveTranslationUseCase,
        historyUseCase: GetHistoryUseCase
    ) {
        self.translateUseCase = translateUseCase
        self.saveUseCase = saveUseCase
        self.historyUseCase = historyUseCase
    }

    func onAppear() {
        view?.render(.idle)
    }

    func didTapTranslate(text: String) {
        let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedText.isEmpty else {
            view?.render(.error("Enter text to translate"))
            return
        }

        task?.cancel()
        view?.render(.loading)
        let request = TranslateRequest(
            text: cleanedText,
            source: sourceLanguage,
            target: targetLanguage,
            style: .formal,
            mode: .auto
        )

        task = Task { [weak self] in
            guard let self else { return }
            do {
                let translation = try await translateUseCase.execute(request)
                guard !Task.isCancelled else { return }
                lastTranslation = translation
                await MainActor.run {
                    self.view?.render(.result(translation.translated))
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.view?.render(.error("Failed to translate"))
                }
            }
        }
    }

    func didSwapLanguages() {
        view?.render(.idle)
    }

    func didTapAddToFavorites() {
        guard let translation = lastTranslation else {
            view?.render(.error("Translate text first"))
            return
        }

        Task {
            do {
                try await saveUseCase.execute(translation)
            } catch {
                await MainActor.run {
                    self.view?.render(.error("Failed to save translation"))
                }
            }
        }
    }

    func handle(event: AppLifecycleEvent) {
        if case .didEnterBackground = event {
            task?.cancel()
        }
        if case .didBecomeActive = event {
            Task { _ = try? await historyUseCase.execute() }
        }
    }
}
