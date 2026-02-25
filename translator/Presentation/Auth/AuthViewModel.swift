final class DefaultAuthViewModel: AuthViewModel {
    private let loginUseCase: LoginUseCase
    private let restoreSessionUseCase: RestoreSessionUseCase

    init(
        loginUseCase: LoginUseCase,
        restoreSessionUseCase: RestoreSessionUseCase
    ) {
        self.loginUseCase = loginUseCase
        self.restoreSessionUseCase = restoreSessionUseCase
    }

    func onAppear() { }

    func didTapLogin(email: String, password: String) { }
}
