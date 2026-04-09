import UIKit

final class FeaturesViewController: UIViewController, FeaturesView {
    private let viewModel: FeaturesViewModelProtocol
    private let onSelectFeature: (FeatureType) -> Void

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private lazy var listManager = FeaturesListManager(tableView: tableView)
    private var featureTypes: [FeatureType] = []

    init(viewModel: FeaturesViewModelProtocol, onSelectFeature: @escaping (FeatureType) -> Void) {
        self.viewModel = viewModel
        self.onSelectFeature = onSelectFeature
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Translator"
        setupUI()
        setupListManager()
        viewModel.onAppear()
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupListManager() {
        listManager.delegate = self
        tableView.delegate = listManager
    }

    func setFeatureTypes(_ types: [FeatureType]) {
        featureTypes = types
    }

    func render(_ state: FeaturesState) {
        switch state {
        case .content(let items):
            listManager.setItems(items, types: featureTypes)
        case .idle:
            break
        }
    }
}

extension FeaturesViewController: FeaturesListManagerDelegate {
    func didSelectFeature(type: FeatureType) {
        onSelectFeature(type)
    }
}
