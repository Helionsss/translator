import UIKit

final class AvailableLanguagesViewController: UIViewController, AvailableLanguagesView {
    private let viewModel: AvailableLanguagesViewModelProtocol
    private let onSelectLanguage: (String) -> Void

    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    private lazy var listManager = AvailableLanguagesListManager(tableView: tableView)
    private lazy var refreshControl = UIRefreshControl()
    private lazy var searchBar = UISearchBar()
    
    private lazy var loadingView = DSLoadingView()
    private lazy var errorView = DSErrorView()
    private lazy var emptyView = DSEmptyView()
    
    private let stateContainer = UIView()

    init(viewModel: AvailableLanguagesViewModelProtocol, onSelectLanguage: @escaping (String) -> Void) {
        self.viewModel = viewModel
        self.onSelectLanguage = onSelectLanguage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Available Languages"
        setupUI()
        setupListManager()
        viewModel.onAppear()
    }

    private func setupUI() {
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.delegate = self

        let searchContainer = UIView()
        searchContainer.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor),
            searchBar.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor)
        ])

        stateContainer.addSubview(tableView)
        [loadingView, errorView, emptyView].forEach { stateView in
            stateContainer.addSubview(stateView)
            stateView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stateView.leadingAnchor.constraint(equalTo: stateContainer.leadingAnchor),
                stateView.trailingAnchor.constraint(equalTo: stateContainer.trailingAnchor),
                stateView.topAnchor.constraint(equalTo: stateContainer.topAnchor),
                stateView.bottomAnchor.constraint(equalTo: stateContainer.bottomAnchor)
            ])
            stateView.isHidden = true
        }

        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: stateContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: stateContainer.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: stateContainer.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: stateContainer.bottomAnchor)
        ])

        view.addSubview(searchContainer)
        view.addSubview(stateContainer)

        searchContainer.translatesAutoresizingMaskIntoConstraints = false
        stateContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            stateContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateContainer.topAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            stateContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        refreshControl.addTarget(self, action: #selector(refreshTapped), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        errorView.onRetry = { [weak self] in
            self?.viewModel.retry()
        }
    }

    private func setupListManager() {
        listManager.delegate = self
        tableView.delegate = listManager
    }

    @objc private func refreshTapped() {
        viewModel.refresh()
    }

    @objc private func retryTapped() {
        viewModel.retry()
    }

    func render(_ state: AvailableLanguagesState) {
        tableView.isHidden = true
        loadingView.isHidden = true
        errorView.isHidden = true
        emptyView.isHidden = true
        searchBar.isUserInteractionEnabled = true
        refreshControl.endRefreshing()
        
        switch state {
        case .idle:
            break
        case .loading:
            loadingView.startAnimating()
            loadingView.isHidden = false
            searchBar.isUserInteractionEnabled = false
        case .content(let items):
            listManager.setItems(items)
            tableView.isHidden = false
        case .empty:
            emptyView.message = "No languages available"
            emptyView.isHidden = false
        case .error(let message):
            errorView.message = message
            errorView.isHidden = false
        }
    }
    
    func showContent() {
        render(.content([]))
    }
    
    func showLoading() {
        render(.loading)
    }
    
    func showError(_ message: String) {
        render(.error(message))
    }
    
    func showEmpty() {
        render(.empty)
    }
}

extension AvailableLanguagesViewController: AvailableLanguagesListManagerDelegate {
    func didSelectLanguage(id: String) {
        onSelectLanguage(id)
    }
}

extension AvailableLanguagesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(query: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}