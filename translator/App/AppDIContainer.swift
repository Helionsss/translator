import UIKit

final class AppDIContainer {

    func makeAuthModule() -> UIViewController {
        fatalError()
    }

    func makeFeaturesModule(session: UserSession) -> UIViewController {
        fatalError()
    }

    func makeTranslateModule(session: UserSession) -> UIViewController {
        fatalError()
    }
}
