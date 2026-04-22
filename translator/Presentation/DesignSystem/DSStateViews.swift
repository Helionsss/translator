import UIKit

final class DSLoadingView: UIView {
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
    
    private func setupView() {
        backgroundColor = DS.Colors.background
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = DS.Spacing.m
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: DS.Spacing.m),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -DS.Spacing.m)
        ])
        
        stack.addArrangedSubview(activityIndicator)
        
        titleLabel.apply(.body)
        titleLabel.text = "Loading..."
        titleLabel.textAlignment = .center
        stack.addArrangedSubview(titleLabel)
    }
}

final class DSErrorView: UIView {
    
    var onRetry: (() -> Void)?
    
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let retryButton = DSButton(style: .primary)
    
    var message: String? {
        get { messageLabel.text }
        set { messageLabel.text = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = DS.Colors.background
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = DS.Spacing.m
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: DS.Spacing.l),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -DS.Spacing.l)
        ])
        
        let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        imageView.tintColor = DS.Colors.error
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        stack.addArrangedSubview(imageView)
        
        titleLabel.apply(.headline)
        titleLabel.text = "Error occurred"
        titleLabel.textAlignment = .center
        stack.addArrangedSubview(titleLabel)
        
        messageLabel.apply(.caption)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        stack.addArrangedSubview(messageLabel)
        
        retryButton.configure(with: DSButton.Configuration(
            title: "Try again",
            accessibilityIdentifier: "retryButton"
        ))
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        stack.setCustomSpacing(DS.Spacing.l, after: messageLabel)
        stack.addArrangedSubview(retryButton)
    }
    
    @objc private func retryTapped() {
        onRetry?()
    }
}

final class DSEmptyView: UIView {
    
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    
    var message: String? {
        get { messageLabel.text }
        set { messageLabel.text = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = DS.Colors.background
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = DS.Spacing.m
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: DS.Spacing.l),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -DS.Spacing.l)
        ])
        
        let imageView = UIImageView(image: UIImage(systemName: "tray"))
        imageView.tintColor = DS.Colors.textSecondary
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        stack.addArrangedSubview(imageView)
        
        titleLabel.apply(.headline)
        titleLabel.text = "Nothing here"
        titleLabel.textAlignment = .center
        stack.addArrangedSubview(titleLabel)
        
        messageLabel.apply(.caption)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        stack.addArrangedSubview(messageLabel)
    }
}