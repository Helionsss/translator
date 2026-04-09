import UIKit

protocol FeaturesListManagerDelegate: AnyObject {
    func didSelectFeature(type: FeatureType)
}

final class FeaturesListManager: NSObject {
    weak var delegate: FeaturesListManagerDelegate?

    private var items: [FeatureCellViewModel] = []
    private var featureTypes: [FeatureType] = []
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

    func setItems(_ items: [FeatureCellViewModel], types: [FeatureType]) {
        self.items = items
        self.featureTypes = types
        applySnapshot(animating: false)
    }

    private func configureDataSource() {
        tableView.register(FeatureMenuCell.self, forCellReuseIdentifier: FeatureMenuCell.reuseIdentifier)

        dataSource = UITableViewDiffableDataSource<Section, String>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
            guard let self else { return nil }
            let viewModel = self.viewModel(for: itemIdentifier)
            let cell = tableView.dequeueReusableCell(withIdentifier: FeatureMenuCell.reuseIdentifier, for: indexPath) as! FeatureMenuCell
            if let viewModel {
                cell.configure(with: viewModel)
            }
            return cell
        }
    }

    private func applySnapshot(animating: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections(Section.allCases)
        let identifiers = items.map(\.id)
        snapshot.appendItems(identifiers, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animating)
    }

    private func viewModel(for id: String) -> FeatureCellViewModel? {
        items.first { $0.id == id }
    }

    private func featureType(for id: String) -> FeatureType? {
        guard let item = items.first(where: { $0.id == id }) else { return nil }
        let index = items.firstIndex(where: { $0.id == id })
        if let index, index < featureTypes.count {
            return featureTypes[index]
        }
        return nil
    }
}

extension FeaturesListManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        if let type = featureType(for: item.id) {
            delegate?.didSelectFeature(type: type)
        }
    }
}