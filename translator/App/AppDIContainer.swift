import UIKit

final class AppDIContainer {

    func makeAuthModule() -> UIViewController {
        let repository = DefaultAuthRepository()
        let loginUseCase = DefaultLoginUseCase(repository: repository)
        let validator = DefaultCredentialsValidator()
        var authVC: AuthViewController!

        authVC = AuthViewController(
            loginUseCase: loginUseCase,
            validator: validator
        ) { [weak self] in
            Task { [weak self] in
                guard
                    let repo = repository as AuthRepository?,
                    let session = await repo.restoreSession(),
                    let features = self?.makeFeaturesModule(session: session)
                else { return }
                if let nav = authVC.navigationController {
                    nav.setViewControllers([features], animated: true)
                } else {
                    authVC.present(features, animated: true)
                }
            }
        }
        return authVC
    }

    func makeFeaturesModule(session: UserSession) -> UIViewController {
        return FeaturesViewController()
    }

    func makeTranslateModule(session: UserSession) -> UIViewController {
        // stub
        return FeaturesViewController()
    }
}
