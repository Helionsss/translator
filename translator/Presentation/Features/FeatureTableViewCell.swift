import UIKit

final class FeatureTableViewCell: UITableViewCell {
    static let reuseIdentifier = "FeatureTableViewCell"

    private let flagImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 4
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let rightTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var imageLoadTask: Task<Void, Never>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(flagImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(rightTextLabel)

        NSLayoutConstraint.activate([
            flagImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            flagImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            flagImageView.widthAnchor.constraint(equalToConstant: 40),
            flagImageView.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.leadingAnchor.constraint(equalTo: flagImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: rightTextLabel.leadingAnchor, constant: -8),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            rightTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rightTextLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightTextLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 80)
        ])

        accessoryType = .disclosureIndicator
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        flagImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        rightTextLabel.text = nil
    }

    func configure(with viewModel: FeatureCellViewModel) {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        rightTextLabel.text = nil
        subtitleLabel.isHidden = viewModel.subtitle == nil
        rightTextLabel.isHidden = true
        flagImageView.image = nil
    }

    func configure(with viewModel: AvailableLanguageCellViewModel) {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        rightTextLabel.text = viewModel.rightText
        subtitleLabel.isHidden = viewModel.subtitle == nil
        rightTextLabel.isHidden = viewModel.rightText == nil

        if let imageURL = viewModel.imageURL {
            if let cached = ImageCache.shared.image(for: imageURL) {
                flagImageView.image = cached
            } else {
                flagImageView.image = nil
                imageLoadTask?.cancel()
                imageLoadTask = Task {
                    do {
                        let image = try await ImageLoader.shared.loadImage(from: imageURL)
                        guard !Task.isCancelled else { return }
                        await MainActor.run {
                            self.flagImageView.image = image
                        }
                    } catch {
                    }
                }
            }
        } else {
            flagImageView.image = nil
        }
    }
}