import UIKit

protocol AppCoordinatorProtocol {
    func start()
}

final class AppCoordinator: AppCoordinatorProtocol {

    private let window: UIWindow
    private let diContainer: AppDIContainer

    init(window: UIWindow, diContainer: AppDIContainer) {
        self.window = window
        self.diContainer = diContainer
    }

    func start() {
        let navigationController = UINavigationController()
        let authVC = diContainer.makeAuthModule()
        navigationController.setViewControllers([authVC], animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
