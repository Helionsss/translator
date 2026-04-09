protocol AvailableLanguagesView: AnyObject {
    func render(_ state: AvailableLanguagesState)
    func showContent()
    func showLoading()
    func showError(_ message: String)
    func showEmpty()
}

protocol AvailableLanguagesViewModelProtocol: AnyObject {
    var view: AvailableLanguagesView? { get set }
    func onAppear()
    func retry()
    func refresh()
    func search(query: String)
    func didSelectLanguage(id: String)
}