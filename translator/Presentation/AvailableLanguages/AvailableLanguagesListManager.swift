import UIKit

protocol AvailableLanguagesListManagerDelegate: AnyObject {
    func didSelectLanguage(id: String)
}

final class AvailableLanguagesListManager: NSObject {
    weak var delegate: AvailableLanguagesListManagerDelegate?

    private var allItems: [AvailableLanguageCellViewModel] = []
    private var filteredItems: [AvailableLanguageCellViewModel] = []
    private var dataSource: UITableViewDiffableDataSource<Section, String>!
    private var tableView: UITableView

    enum Section: Int, CaseIterable {
        case main
    }

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        configureDataSource()
    }

    func setItems(_ items: [AvailableLanguageCellViewModel]) {
        allItems = items
        filteredItems = items
        applySnapshot(animating: false)
    }

    func filter(by query: String) {
        if query.isEmpty {
            filteredItems = allItems
        } else {
            let lowercased = query.lowercased()
            filteredItems = allItems.filter {
                $0.title.lowercased().contains(lowercased) ||
                ($0.subtitle?.lowercased().contains(lowercased) ?? false)
            }
        }
        applySnapshot(animating: true)
    }

    func reload() {
        applySnapshot(animating: false)
    }

    var isEmpty: Bool {
        filteredItems.isEmpty
    }

    var hasItems: Bool {
        !allItems.isEmpty
    }

    private func configureDataSource() {
        tableView.register(FeatureTableViewCell.self, forCellReuseIdentifier: FeatureTableViewCell.reuseIdentifier)

        dataSource = UITableViewDiffableDataSource<Section, String>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
            guard let self else { return nil }
            let viewModel = self.viewModel(for: itemIdentifier)
            let cell = tableView.dequeueReusableCell(withIdentifier: FeatureTableViewCell.reuseIdentifier, for: indexPath) as! FeatureTableViewCell
            if let viewModel {
                cell.configure(with: viewModel)
            }
            return cell
        }
    }

    private func applySnapshot(animating: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections(Section.allCases)
        let identifiers = filteredItems.map(\.id)
        snapshot.appendItems(identifiers, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animating)
    }

    private func viewModel(for id: String) -> AvailableLanguageCellViewModel? {
        filteredItems.first { $0.id == id }
    }
}

extension AvailableLanguagesListManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = filteredItems[indexPath.row]
        delegate?.didSelectLanguage(id: item.id)
    }
}