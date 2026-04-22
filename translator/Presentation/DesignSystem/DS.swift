import UIKit

enum DS {

    enum Colors {
        static let background = UIColor.systemBackground
        static let secondaryBackground = UIColor.secondarySystemBackground
        static let primary = UIColor.systemBlue
        static let textPrimary = UIColor.label
        static let textSecondary = UIColor.secondaryLabel
        static let error = UIColor.systemRed
        static let tint = UIColor.systemBlue
        static let separator = UIColor.separator
    }
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
        
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
    }
    
    enum Typography {
        static func title() -> UIFont { .systemFont(ofSize: 28, weight: .bold) }
        static func headline() -> UIFont { .systemFont(ofSize: 20, weight: .semibold) }
        static func body() -> UIFont { .systemFont(ofSize: 16, weight: .regular) }
        static func caption() -> UIFont { .systemFont(ofSize: 13, weight: .regular) }
        static func error() -> UIFont { .systemFont(ofSize: 13, weight: .medium) }
    }
    
    enum TextStyle {
        case title, headline, body, caption, error
    }
}

extension UILabel {
    func apply(_ style: DS.TextStyle) {
        switch style {
        case .title:
            font = DS.Typography.title()
            textColor = DS.Colors.textPrimary
        case .headline:
            font = DS.Typography.headline()
            textColor = DS.Colors.textPrimary
        case .body:
            font = DS.Typography.body()
            textColor = DS.Colors.textPrimary
        case .caption:
            font = DS.Typography.caption()
            textColor = DS.Colors.textSecondary
        case .error:
            font = DS.Typography.error()
            textColor = DS.Colors.error
        }
    }
}
