import UIKit

final class FeatureDetailViewController: UIViewController {
    private let featureId: String
    private let featureTitle: String
    private let featureSubtitle: String?

    private let stack = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let descriptionLabel = UILabel()

    init(featureId: String, title: String, subtitle: String?) {
        self.featureId = featureId
        self.featureTitle = title
        self.featureSubtitle = subtitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = featureTitle

        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])

        titleLabel.text = featureTitle
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.textAlignment = .center
        stack.addArrangedSubview(titleLabel)

        if let subtitle = featureSubtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.font = .preferredFont(forTextStyle: .body)
            subtitleLabel.textColor = .secondaryLabel
            subtitleLabel.textAlignment = .center
            stack.addArrangedSubview(subtitleLabel)
        }

        descriptionLabel.text = "Feature ID: \(featureId)\n\nThis is a detail screen for the selected feature. Full implementation would show additional details, settings, or functionality related to this feature."
        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        stack.addArrangedSubview(descriptionLabel)
    }
}