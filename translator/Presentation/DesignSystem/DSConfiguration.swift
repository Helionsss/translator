import UIKit

protocol DSConfigurable {
    associatedtype Configuration
    func configure(with config: Configuration)
}

struct DSDynamicProperties {
    var accessibilityIdentifier: String?
    var accessibilityLabel: String?
    var accessibilityHint: String?
    var tag: Int?
    var isAccessibilityElement: Bool
    
    init(
        accessibilityIdentifier: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        tag: Int? = nil,
        isAccessibilityElement: Bool = true
    ) {
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.tag = tag
        self.isAccessibilityElement = isAccessibilityElement
    }
    
    func apply(to view: UIView) {
        if let identifier = accessibilityIdentifier {
            view.accessibilityIdentifier = identifier
        }
        if let label = accessibilityLabel {
            view.accessibilityLabel = label
        }
        if let hint = accessibilityHint {
            view.accessibilityHint = hint
        }
        if let tag = tag {
            view.tag = tag
        }
        view.isAccessibilityElement = isAccessibilityElement
    }
}

final class DSConfigurationManager {
    
    static let shared = DSConfigurationManager()
    
    private init() {}
    
    var supportsDynamicColors: Bool = true
    var supportsDynamicType: Bool = true
    
    private var _customColors: [String: UIColor] = [:]
    private var _customSpacing: [String: CGFloat] = [:]
    
    func registerColor(_ color: UIColor, forKey key: String) {
        _customColors[key] = color
    }
    
    func registerSpacing(_ spacing: CGFloat, forKey key: String) {
        _customSpacing[key] = spacing
    }
    
    func customColor(forKey key: String) -> UIColor? {
        _customColors[key]
    }
    
    func customSpacing(forKey key: String) -> CGFloat? {
        _customSpacing[key]
    }
    
    func reset() {
        _customColors.removeAll()
        _customSpacing.removeAll()
    }
}

extension UIView {
    
    func applyDSProperties(_ properties: DSDynamicProperties) {
        properties.apply(to: self)
    }
    
    func withDSProperties(_ properties: DSDynamicProperties) -> Self {
        applyDSProperties(properties)
        return self
    }
}
