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
        let repository = DefaultFeaturesRepository(networkClient: networkClient)
        let useCase = DefaultGetAvailableFeaturesUseCase(repository: repository)
        let viewModel = DefaultFeaturesViewModel(useCase: useCase) { [weak self] featureId in
            _ = self?.makeTranslateModule(session: session)
        }
        let vc = FeaturesViewController(viewModel: viewModel)
        viewModel.view = vc
        return vc
    }

    func makeTranslateModule(session: UserSession) -> UIViewController {
        return FeaturesViewController(viewModel: makeFeaturesStubViewModel())
    }

    private func makeFeaturesStubViewModel() -> FeaturesViewModelProtocol {
        let repository = DefaultFeaturesRepository(networkClient: networkClient)
        let useCase = DefaultGetAvailableFeaturesUseCase(repository: repository)
        return DefaultFeaturesViewModel(useCase: useCase, onSelectFeature: { _ in })
    }
}
