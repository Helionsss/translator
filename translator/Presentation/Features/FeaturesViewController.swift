import UIKit

final class FeaturesViewController: UIViewController, FeaturesView {
    private let viewModel: FeaturesViewModelProtocol
    private let onSelectFeature: (FeatureType) -> Void

    private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped)
    private lazy var listManager = FeaturesListManager(tableView: tableView)
    private var featureTypes: [FeatureType] = []
    
    private lazy var loadingView = DSLoadingView()
    private lazy var errorView = DSErrorView()
    private lazy var emptyView = DSEmptyView()

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
        view.backgroundColor = DS.Colors.background
        title = "Translator"
        setupUI()
        setupListManager()
        setupStateViews()
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
        
        tableView.backgroundColor = DS.Colors.background
    }

    private func setupListManager() {
        listManager.delegate = self
        tableView.delegate = listManager
    }
    
    private func setupStateViews() {
        [loadingView, errorView, emptyView].forEach { stateView in
            view.addSubview(stateView)
            stateView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                stateView.topAnchor.constraint(equalTo: view.topAnchor),
                stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            stateView.isHidden = true
        }
        
        errorView.onRetry = { [weak self] in
            self?.viewModel.onAppear()
        }
    }

    func setFeatureTypes(_ types: [FeatureType]) {
        featureTypes = types
    }

    func render(_ state: FeaturesState) {
        tableView.isHidden = true
        loadingView.isHidden = true
        errorView.isHidden = true
        emptyView.isHidden = true
        
        switch state {
        case .content(let items):
            if items.isEmpty {
                emptyView.message = "No features available"
                emptyView.isHidden = false
            } else {
                listManager.setItems(items, types: featureTypes)
                tableView.isHidden = false
            }
        case .loading:
            loadingView.startAnimating()
            loadingView.isHidden = false
        case .error(let message):
            errorView.message = message
            errorView.isHidden = false
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