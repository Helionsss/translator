import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinatorProtocol?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)

        let diContainer = AppDIContainer()
        let coordinator = AppCoordinator(window: window, diContainer: diContainer)
        self.appCoordinator = coordinator
        coordinator.start()

        self.window = window
    }
}
