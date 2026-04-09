import UIKit

final class AppDIContainer {

    private let networkClient: NetworkClient = URLSessionNetworkClient()

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
        let viewModel = DefaultFeaturesViewModel { [weak self] type in
            self?.handleFeatureSelection(type, session: session)
        }
        let vc = FeaturesViewController(viewModel: viewModel) { [weak self] type in
            self?.handleFeatureSelection(type, session: session)
        }
        viewModel.view = vc
        return vc
    }

    func makeAvailableLanguagesModule(session: UserSession) -> UIViewController {
        let repository = DefaultFeaturesRepository(networkClient: networkClient)
        let useCase = DefaultGetAvailableFeaturesUseCase(repository: repository)
        let viewModel = DefaultAvailableLanguagesViewModel(useCase: useCase) { [weak self] languageId in
            self?.makeTranslateModule(session: session, languageId: languageId)
        }
        let vc = AvailableLanguagesViewController(viewModel: viewModel) { [weak self] languageId in
            self?.makeTranslateModule(session: session, languageId: languageId)
        }
        viewModel.view = vc
        return vc
    }

    func makeTranslateModule(session: UserSession, languageId: String? = nil) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = "Translate"
        let label = UILabel()
        label.text = languageId.map { "Translate (\($0))" } ?? "Translate"
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        return vc
    }

    private func handleFeatureSelection(_ type: FeatureType, session: UserSession) {
        guard let nav = UIApplication.shared.windows.first?.rootViewController as? UINavigationController else { return }
        switch type {
        case .translate:
            let vc = makeTranslateModule(session: session)
            nav.pushViewController(vc, animated: true)
        case .languages:
            let vc = makeAvailableLanguagesModule(session: session)
            nav.pushViewController(vc, animated: true)
        case .history, .favorites, .settings:
            let vc = makeStubModule(title: type.rawValue.capitalized)
            nav.pushViewController(vc, animated: true)
        }
    }

    private func makeStubModule(title: String) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = title
        let label = UILabel()
        label.text = "\(title) — Coming Soon"
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        return vc
    }
}