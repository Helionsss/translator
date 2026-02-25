import Foundation

enum AuthViewState: Equatable {
    case idle
    case loading
    case error(String)
}

protocol AuthView: AnyObject {
    func render(_ state: AuthViewState)
}

protocol AuthViewModel {
    func onAppear()
    func didTapLogin(email: String, password: String)
}
