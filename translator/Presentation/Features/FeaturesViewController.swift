import UIKit

final class FeaturesViewController: UIViewController, FeaturesView {
    private let viewModel: FeaturesViewModelProtocol

    init(viewModel: FeaturesViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Features"
        viewModel.onAppear()
    }

    func render(_ state: FeaturesState) {
        switch state {
        case .idle:
            break
        case .loading:
            print("[FeaturesVC] loading…")
        case .content(let items):
            print("[FeaturesVC] loaded \(items.count) items: \(items.map(\.title))")
        case .empty:
            print("[FeaturesVC] empty")
        case .error(let message):
            print("[FeaturesVC] error: \(message)")
        }
    }
}
