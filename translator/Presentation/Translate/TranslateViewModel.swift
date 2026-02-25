final class DefaultTranslateViewModel:
    TranslateViewModel,
    AppLifecycleListener {
    private let translateUseCase: TranslateUseCase
    private let saveUseCase: SaveTranslationUseCase
    private let historyUseCase: GetHistoryUseCase

    init(
        translateUseCase: TranslateUseCase,
        saveUseCase: SaveTranslationUseCase,
        historyUseCase: GetHistoryUseCase
    ) {
        self.translateUseCase = translateUseCase
        self.saveUseCase = saveUseCase
        self.historyUseCase = historyUseCase
    }

    func onAppear() { }

    func didTapTranslate(text: String) { }

    func didSwapLanguages() { }

    func didTapAddToFavorites() { }

    func handle(event: AppLifecycleEvent) { }
}
