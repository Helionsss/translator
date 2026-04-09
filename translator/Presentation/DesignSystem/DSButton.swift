import UIKit

final class DSButton: UIButton {
    
    enum Style {
        case primary
        case secondary
    }
    
    struct Configuration {
        var title: String
        var accessibilityIdentifier: String?
        var dynamicProperties: DSDynamicProperties?
        
        init(title: String, accessibilityIdentifier: String? = nil, dynamicProperties: DSDynamicProperties? = nil) {
            self.title = title
            self.accessibilityIdentifier = accessibilityIdentifier
            self.dynamicProperties = dynamicProperties
        }
        
        static func make(title: String, accessibilityIdentifier: String? = nil) -> Configuration {
            Configuration(title: title, accessibilityIdentifier: accessibilityIdentifier)
        }
    }
    
    private let style: Style
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        applyStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with config: Configuration) {
        setTitle(config.title, for: .normal)
        if let identifier = config.accessibilityIdentifier {
            accessibilityIdentifier = identifier
        }
        if let props = config.dynamicProperties {
            applyDSProperties(props)
        }
    }
    
    @discardableResult
    func configureAccessibility(identifier: String? = nil, label: String? = nil, hint: String? = nil) -> DSButton {
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
    
    override var isEnabled: Bool {
        didSet {
            updateState()
        }
    }
    
    private func applyStyle() {
        layer.cornerRadius = DS.Spacing.cornerRadius
        titleLabel?.font = DS.Typography.body()
        contentEdgeInsets = UIEdgeInsets(top: DS.Spacing.m, left: DS.Spacing.m, bottom: DS.Spacing.m, right: DS.Spacing.m)
        updateState()
    }
    
    private func updateState() {
        switch style {
        case .primary:
            backgroundColor = isEnabled ? DS.Colors.primary : DS.Colors.primary.withAlphaComponent(0.5)
            setTitleColor(.white, for: .normal)
            setTitleColor(.white.withAlphaComponent(0.5), for: .disabled)
        case .secondary:
            backgroundColor = .clear
            setTitleColor(DS.Colors.primary, for: .normal)
            setTitleColor(DS.Colors.primary.withAlphaComponent(0.5), for: .disabled)
        }
    }
}
