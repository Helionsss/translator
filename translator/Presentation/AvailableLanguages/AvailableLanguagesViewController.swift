import UIKit

final class AvailableLanguagesViewController: UIViewController, AvailableLanguagesView {
    private let viewModel: AvailableLanguagesViewModelProtocol
    private let onSelectLanguage: (String) -> Void

    private let tableView = UITableView(frame: .zero, style: .plain)
    private lazy var listManager = AvailableLanguagesListManager(tableView: tableView)

    private let refreshControl = UIRefreshControl()
    private let searchBar = UISearchBar()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No languages available"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

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
        stateContainer.addSubview(emptyLabel)
        stateContainer.addSubview(errorLabel)
        stateContainer.addSubview(retryButton)
        stateContainer.addSubview(loadingIndicator)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: stateContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: stateContainer.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: stateContainer.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: stateContainer.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: stateContainer.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: stateContainer.centerYAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: stateContainer.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: stateContainer.centerYAnchor, constant: -20),

            retryButton.centerXAnchor.constraint(equalTo: stateContainer.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 12)
        ])

        loadingIndicator.center = stateContainer.center

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

        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
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
        switch state {
        case .idle:
            break
        case .loading:
            showLoading()
        case .content(let items):
            listManager.setItems(items)
            showContent()
        case .empty:
            showEmpty()
        case .error(let message):
            showError(message)
        }
    }

    func showLoading() {
        tableView.isHidden = true
        emptyLabel.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        searchBar.isUserInteractionEnabled = false
    }

    func showContent() {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        emptyLabel.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
        tableView.isHidden = false
        searchBar.isUserInteractionEnabled = true
        refreshControl.endRefreshing()
    }

    func showEmpty() {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        tableView.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
        emptyLabel.isHidden = false
        searchBar.isUserInteractionEnabled = true
        refreshControl.endRefreshing()
    }

    func showError(_ message: String) {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        tableView.isHidden = true
        emptyLabel.isHidden = true
        errorLabel.text = message
        errorLabel.isHidden = false
        retryButton.isHidden = false
        searchBar.isUserInteractionEnabled = true
        refreshControl.endRefreshing()
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