import UIKit

final class DefaultBDUIViewMapper: BDUIViewMapping {
    private let layoutApplier: BDUILayoutApplying
    private(set) var renderContext = BDUIRenderContext()

    init(layoutApplier: BDUILayoutApplying = DefaultBDUILayoutApplier()) {
        self.layoutApplier = layoutApplier
    }

    func map(model: BDUIViewNode, actionHandler: BDUIActionHandling) throws -> UIView {
        renderContext = BDUIRenderContext()
        return try build(node: model, parent: nil, actionHandler: actionHandler)
    }

    private func build(node: BDUIViewNode, parent: UIView?, actionHandler: BDUIActionHandling) throws -> UIView {
        let built = try makeView(for: node)
        let view = built.view

        if let id = node.id {
            renderContext.viewsById[id] = view
        }

        if let parent {
            attach(view: view, to: parent)
            layoutApplier.applyLayout(node: node, view: view, parent: parent)
        } else {
            layoutApplier.applyLayout(node: node, view: view, parent: nil)
        }

        bindActionsIfNeeded(node: node, view: view, actionHandler: actionHandler)

        let childParent = built.childContainer
        for childNode in node.subviews {
            _ = try build(node: childNode, parent: childParent, actionHandler: actionHandler)
        }
        return view
    }

    private func makeView(for node: BDUIViewNode) throws -> (view: UIView, childContainer: UIView) {
        switch node.type {
        case .contentView, .containerView:
            let view = UIView()
            if case .container(let content) = node.content, let color = content.backgroundColor?.color {
                view.backgroundColor = color
            }
            return (view, view)

        case .stackView:
            let stack = UIStackView()
            stack.axis = node.layout?.axis?.axis ?? .vertical
            stack.spacing = node.layout?.spacing?.value ?? DS.Spacing.m
            stack.alignment = node.layout?.alignment?.stackAlignment ?? .fill
            stack.distribution = node.layout?.distribution?.stackDistribution ?? .fill
            if case .stack(let content) = node.content {
                if let axis = content.axis?.axis { stack.axis = axis }
                if let spacing = content.spacing?.value { stack.spacing = spacing }
                if let alignment = content.alignment?.stackAlignment { stack.alignment = alignment }
                if let distribution = content.distribution?.stackDistribution { stack.distribution = distribution }
            }
            return (stack, stack)

        case .label:
            guard case .label(let content) = node.content else {
                throw BDUIMapperError.unsupportedContent(.label)
            }
            let label = UILabel()
            label.text = content.text
            label.apply(content.textStyle?.style ?? .body)
            if let color = content.textColor?.color {
                label.textColor = color
            }
            label.numberOfLines = content.numberOfLines ?? 0
            label.textAlignment = content.textAlignment?.value ?? .natural
            return (label, label)

        case .button:
            guard case .button(let content) = node.content else {
                throw BDUIMapperError.unsupportedContent(.button)
            }
            let button = DSButton(style: content.style?.style ?? .primary)
            button.configure(with: .make(title: content.title))
            return (button, button)

        case .textField:
            let textField = DSTextField()
            if case .textField(let content) = node.content {
                textField.configure(with: .init(
                    title: content.title,
                    placeholder: content.placeholder,
                    text: content.text
                ))
                textField.isSecureTextEntry = content.isSecure ?? false
                textField.keyboardType = content.keyboardType?.type ?? .default
            }
            return (textField, textField)

        case .imageView:
            guard case .image(let content) = node.content else {
                throw BDUIMapperError.unsupportedContent(.imageView)
            }
            let imageView = UIImageView(image: UIImage(systemName: content.systemName))
            imageView.tintColor = content.tintColor?.color ?? DS.Colors.tint
            imageView.contentMode = content.contentMode?.mode ?? .scaleAspectFit
            return (imageView, imageView)

        case .spacer:
            let spacer = UIView()
            spacer.backgroundColor = .clear
            spacer.translatesAutoresizingMaskIntoConstraints = false
            if case .spacer(let content) = node.content {
                spacer.heightAnchor.constraint(equalToConstant: content.height ?? DS.Spacing.m).isActive = true
            } else {
                spacer.heightAnchor.constraint(equalToConstant: DS.Spacing.m).isActive = true
            }
            return (spacer, spacer)

        case .separator:
            let separator = UIView()
            separator.backgroundColor = DS.Colors.separator
            separator.translatesAutoresizingMaskIntoConstraints = false
            if case .separator(let content) = node.content {
                separator.backgroundColor = content.color?.color ?? DS.Colors.separator
                separator.heightAnchor.constraint(equalToConstant: content.thickness ?? 1).isActive = true
            } else {
                separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            }
            return (separator, separator)

        case .scrollView:
            let scrollView = UIScrollView()
            if case .scroll(let content) = node.content {
                scrollView.showsVerticalScrollIndicator = content.showsVerticalIndicator ?? true
                scrollView.showsHorizontalScrollIndicator = content.showsHorizontalIndicator ?? false
            }

            let contentView = UIView()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(contentView)
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
                contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
            ])
            return (scrollView, contentView)
        }
    }

    private func attach(view child: UIView, to parent: UIView) {
        if let stack = parent as? UIStackView {
            stack.addArrangedSubview(child)
            return
        }
        parent.addSubview(child)
    }

    private func bindActionsIfNeeded(node: BDUIViewNode, view: UIView, actionHandler: BDUIActionHandling) {
        guard let actions = node.actions else { return }

        if let tapAction = actions["tap"] {
            if let control = view as? UIControl {
                control.bdui_addAction(for: .touchUpInside) { [weak actionHandler, weak view, weak self] in
                    guard let actionHandler, let view, let self else { return }
                    actionHandler.handle(action: tapAction, sourceView: view, context: self.renderContext)
                }
            } else {
                let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
                recognizer.bduiAction = tapAction
                recognizer.bduiActionHandler = actionHandler
                recognizer.bduiContextProvider = { [weak self] in self?.renderContext }
                view.isUserInteractionEnabled = true
                view.addGestureRecognizer(recognizer)
            }
        }

        if let editingChangedAction = actions["editingChanged"], let textField = view as? DSTextField {
            textField.textField.bdui_addAction(for: .editingChanged) { [weak actionHandler, weak view, weak self] in
                guard let actionHandler, let view, let self else { return }
                actionHandler.handle(action: editingChangedAction, sourceView: view, context: self.renderContext)
            }
        }
    }

    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        guard
            let action = recognizer.bduiAction,
            let view = recognizer.view,
            let handler = recognizer.bduiActionHandler,
            let context = recognizer.bduiContextProvider?()
        else { return }

        handler.handle(action: action, sourceView: view, context: context)
    }
}
