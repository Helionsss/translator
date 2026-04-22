import UIKit

enum BDUIViewType: String, Decodable {
    case contentView
    case containerView
    case stackView
    case label
    case button
    case textField
    case imageView
    case spacer
    case separator
    case scrollView
}

enum DSColorToken: String, Decodable {
    case background
    case secondaryBackground
    case primary
    case textPrimary
    case textSecondary
    case error
    case tint
    case separator
    case white
    case clear

    var color: UIColor {
        switch self {
        case .background: return DS.Colors.background
        case .secondaryBackground: return DS.Colors.secondaryBackground
        case .primary: return DS.Colors.primary
        case .textPrimary: return DS.Colors.textPrimary
        case .textSecondary: return DS.Colors.textSecondary
        case .error: return DS.Colors.error
        case .tint: return DS.Colors.tint
        case .separator: return DS.Colors.separator
        case .white: return .white
        case .clear: return .clear
        }
    }
}

enum DSSpacingToken: String, Decodable {
    case xs
    case s
    case m
    case l
    case xl

    var value: CGFloat {
        switch self {
        case .xs: return DS.Spacing.xs
        case .s: return DS.Spacing.s
        case .m: return DS.Spacing.m
        case .l: return DS.Spacing.l
        case .xl: return DS.Spacing.xl
        }
    }
}

enum DSTextStyleToken: String, Decodable {
    case title
    case headline
    case body
    case caption
    case error

    var style: DS.TextStyle {
        switch self {
        case .title: return .title
        case .headline: return .headline
        case .body: return .body
        case .caption: return .caption
        case .error: return .error
        }
    }
}

enum BDUIAxis: String, Decodable {
    case vertical
    case horizontal

    var axis: NSLayoutConstraint.Axis {
        switch self {
        case .vertical: return .vertical
        case .horizontal: return .horizontal
        }
    }
}

enum BDUIAlignment: String, Decodable {
    case fill
    case leading
    case center
    case trailing

    var stackAlignment: UIStackView.Alignment {
        switch self {
        case .fill: return .fill
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

enum BDUIDistribution: String, Decodable {
    case fill
    case fillEqually
    case equalSpacing

    var stackDistribution: UIStackView.Distribution {
        switch self {
        case .fill: return .fill
        case .fillEqually: return .fillEqually
        case .equalSpacing: return .equalSpacing
        }
    }
}

enum BDUISizeContentMode: String, Decodable {
    case fill
    case fit
    case center

    var mode: UIView.ContentMode {
        switch self {
        case .fill: return .scaleToFill
        case .fit: return .scaleAspectFit
        case .center: return .center
        }
    }
}

enum BDUITextAlignment: String, Decodable {
    case left
    case center
    case right
    case natural

    var value: NSTextAlignment {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        case .natural: return .natural
        }
    }
}

enum BDUIButtonStyleToken: String, Decodable {
    case primary
    case secondary

    var style: DSButton.Style {
        switch self {
        case .primary: return .primary
        case .secondary: return .secondary
        }
    }
}

enum BDUIKeyboardType: String, Decodable {
    case `default`
    case emailAddress

    var type: UIKeyboardType {
        switch self {
        case .default: return .default
        case .emailAddress: return .emailAddress
        }
    }
}

struct BDUIEdgeInsets: Decodable {
    let top: CGFloat
    let left: CGFloat
    let bottom: CGFloat
    let right: CGFloat

    var value: UIEdgeInsets {
        UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
}

struct BDUIFixedSize: Decodable {
    let width: CGFloat?
    let height: CGFloat?
}

struct BDUILayout: Decodable {
    let spacing: DSSpacingToken?
    let axis: BDUIAxis?
    let alignment: BDUIAlignment?
    let distribution: BDUIDistribution?
    let contentInsets: BDUIEdgeInsets?
    let backgroundColor: DSColorToken?
    let cornerRadius: CGFloat?
    let fixedSize: BDUIFixedSize?
}

struct BDUIConstraints: Decodable {
    let pinToSuperview: Bool?
    let top: CGFloat?
    let left: CGFloat?
    let bottom: CGFloat?
    let right: CGFloat?
    let centerX: Bool?
    let centerY: Bool?
    let width: CGFloat?
    let height: CGFloat?
}

struct BDUIContainerContent: Decodable {
    let backgroundColor: DSColorToken?
}

struct BDUIStackContent: Decodable {
    let spacing: DSSpacingToken?
    let axis: BDUIAxis?
    let alignment: BDUIAlignment?
    let distribution: BDUIDistribution?
}

struct BDUILabelContent: Decodable {
    let text: String
    let textStyle: DSTextStyleToken?
    let textColor: DSColorToken?
    let numberOfLines: Int?
    let textAlignment: BDUITextAlignment?
}

struct BDUIButtonContent: Decodable {
    let title: String
    let style: BDUIButtonStyleToken?
}

struct BDUITextFieldContent: Decodable {
    let placeholder: String?
    let text: String?
    let isSecure: Bool?
    let keyboardType: BDUIKeyboardType?
    let title: String?
}

struct BDUIImageContent: Decodable {
    let systemName: String
    let tintColor: DSColorToken?
    let contentMode: BDUISizeContentMode?
}

struct BDUISpacerContent: Decodable {
    let height: CGFloat?
}

struct BDUISeparatorContent: Decodable {
    let color: DSColorToken?
    let thickness: CGFloat?
}

struct BDUIScrollContent: Decodable {
    let showsVerticalIndicator: Bool?
    let showsHorizontalIndicator: Bool?
}

enum BDUIViewContent: Decodable {
    case container(BDUIContainerContent)
    case stack(BDUIStackContent)
    case label(BDUILabelContent)
    case button(BDUIButtonContent)
    case textField(BDUITextFieldContent)
    case image(BDUIImageContent)
    case spacer(BDUISpacerContent)
    case separator(BDUISeparatorContent)
    case scroll(BDUIScrollContent)

    init(from decoder: Decoder) throws {
        throw DecodingError.dataCorrupted(
            .init(codingPath: decoder.codingPath, debugDescription: "Use BDUIViewNode decoder")
        )
    }
}

struct BDUIAction: Decodable {
    let kind: String
    let destination: String?
    let targetId: String?
    let value: String?
    let message: String?

    private enum CodingKeys: String, CodingKey {
        case kind = "type"
        case destination
        case targetId
        case value
        case message
    }
}

struct BDUIViewNode: Decodable {
    let id: String?
    let type: BDUIViewType
    let content: BDUIViewContent?
    let layout: BDUILayout?
    let constraints: BDUIConstraints?
    let subviews: [BDUIViewNode]
    let actions: [String: BDUIAction]?

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case content
        case layout
        case constraints
        case subviews
        case actions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        type = try container.decode(BDUIViewType.self, forKey: .type)
        layout = try container.decodeIfPresent(BDUILayout.self, forKey: .layout)
        constraints = try container.decodeIfPresent(BDUIConstraints.self, forKey: .constraints)
        subviews = try container.decodeIfPresent([BDUIViewNode].self, forKey: .subviews) ?? []
        actions = try container.decodeIfPresent([String: BDUIAction].self, forKey: .actions)

        switch type {
        case .contentView, .containerView:
            if let value = try container.decodeIfPresent(BDUIContainerContent.self, forKey: .content) {
                content = .container(value)
            } else {
                content = nil
            }
        case .stackView:
            if let value = try container.decodeIfPresent(BDUIStackContent.self, forKey: .content) {
                content = .stack(value)
            } else {
                content = nil
            }
        case .label:
            content = .label(try container.decode(BDUILabelContent.self, forKey: .content))
        case .button:
            content = .button(try container.decode(BDUIButtonContent.self, forKey: .content))
        case .textField:
            if let value = try container.decodeIfPresent(BDUITextFieldContent.self, forKey: .content) {
                content = .textField(value)
            } else {
                content = nil
            }
        case .imageView:
            content = .image(try container.decode(BDUIImageContent.self, forKey: .content))
        case .spacer:
            if let value = try container.decodeIfPresent(BDUISpacerContent.self, forKey: .content) {
                content = .spacer(value)
            } else {
                content = nil
            }
        case .separator:
            if let value = try container.decodeIfPresent(BDUISeparatorContent.self, forKey: .content) {
                content = .separator(value)
            } else {
                content = nil
            }
        case .scrollView:
            if let value = try container.decodeIfPresent(BDUIScrollContent.self, forKey: .content) {
                content = .scroll(value)
            } else {
                content = nil
            }
        }
    }
}

protocol BDUIViewMapping {
    var renderContext: BDUIRenderContext { get }
    func map(model: BDUIViewNode, actionHandler: BDUIActionHandling) throws -> UIView
}

protocol BDUIActionHandling: AnyObject {
    func handle(action: BDUIAction, sourceView: UIView, context: BDUIRenderContext)
}

protocol BDUILayoutApplying {
    func applyLayout(node: BDUIViewNode, view: UIView, parent: UIView?)
}

final class BDUIRenderContext {
    var viewsById: [String: UIView] = [:]
}
