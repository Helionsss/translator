enum TranslateViewState: Equatable {
    case idle
    case loading
    case result(String)
    case error(String)
}

protocol TranslateView: AnyObject {
    func render(_ state: TranslateViewState)
}

protocol TranslateViewModel {
    func onAppear()
    func didTapTranslate(text: String)
    func didSwapLanguages()
    func didTapAddToFavorites()
}
