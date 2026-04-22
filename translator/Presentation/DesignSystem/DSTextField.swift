import UIKit

final class DSTextField: UIView {
    
    struct Configuration {
        var title: String?
        var placeholder: String?
        var text: String?
        var accessibilityIdentifier: String?
        var dynamicProperties: DSDynamicProperties?
        
        init(
            title: String? = nil,
            placeholder: String? = nil,
            text: String? = nil,
            accessibilityIdentifier: String? = nil,
            dynamicProperties: DSDynamicProperties? = nil
        ) {
            self.title = title
            self.placeholder = placeholder
            self.text = text
            self.accessibilityIdentifier = accessibilityIdentifier
            self.dynamicProperties = dynamicProperties
        }
    }
    
    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }
    
    var placeholder: String? {
        get { textField.placeholder }
        set { textField.placeholder = newValue }
    }
    
    var isSecureTextEntry: Bool {
        get { textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }
    
    var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }
    
    var textContentType: UITextContentType? {
        get { textField.textContentType }
        set { textField.textContentType = newValue }
    }
    
    var returnKeyType: UIReturnKeyType {
        get { textField.returnKeyType }
        set { textField.returnKeyType = newValue }
    }
    
    var error: String? {
        didSet { updateErrorState() }
    }
    
    weak var delegate: UITextFieldDelegate? {
        get { textField.delegate }
        set { textField.delegate = newValue }
    }
    
    private let titleLabel = UILabel()
    let textField = UITextField()
    private let errorLabel = UILabel()
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with config: Configuration) {
        titleLabel.text = config.title
        titleLabel.isHidden = config.title == nil
        textField.placeholder = config.placeholder
        textField.text = config.text
        if let identifier = config.accessibilityIdentifier {
            accessibilityIdentifier = identifier
        }
        if let props = config.dynamicProperties {
            applyDSProperties(props)
        }
    }
    
    @discardableResult
    func configureAccessibility(identifier: String? = nil, label: String? = nil, hint: String? = nil) -> DSTextField {
        if let id = identifier {
            accessibilityIdentifier = id
        }
        if let lbl = label {
            accessibilityLabel = lbl
        }
        if let hnt = hint {
            accessibilityHint = hnt
        }
        return self
    }
    
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        textField.addTarget(target, action: action, for: controlEvents)
    }
    
    private func setupView() {
        stackView.axis = .vertical
        stackView.spacing = DS.Spacing.xs
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        titleLabel.apply(.caption)
        titleLabel.isHidden = true
        stackView.addArrangedSubview(titleLabel)
        
        textField.borderStyle = .roundedRect
        textField.font = DS.Typography.body()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        stackView.addArrangedSubview(textField)
        
        errorLabel.apply(.error)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        stackView.addArrangedSubview(errorLabel)
    }
    
    private func updateErrorState() {
        errorLabel.text = error
        errorLabel.isHidden = error == nil || error?.isEmpty == true
    }
}
