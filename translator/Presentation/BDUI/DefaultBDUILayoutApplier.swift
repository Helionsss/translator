import UIKit

final class DefaultBDUILayoutApplier: BDUILayoutApplying {
    func applyLayout(node: BDUIViewNode, view: UIView, parent: UIView?) {
        let hasFixedConstraints = node.layout?.fixedSize?.width != nil || node.layout?.fixedSize?.height != nil
        let c = node.constraints
        let hasNodeConstraints = c?.pinToSuperview == true || c?.top != nil || c?.left != nil || c?.bottom != nil || c?.right != nil || c?.centerX == true || c?.centerY == true || c?.width != nil || c?.height != nil
        if hasFixedConstraints || hasNodeConstraints {
            view.translatesAutoresizingMaskIntoConstraints = false
        }

        if let color = node.layout?.backgroundColor?.color {
            view.backgroundColor = color
        }
        if let radius = node.layout?.cornerRadius {
            view.layer.cornerRadius = radius
            view.clipsToBounds = true
        }
        if let fixed = node.layout?.fixedSize {
            if let width = fixed.width {
                view.widthAnchor.constraint(equalToConstant: width).isActive = true
            }
            if let height = fixed.height {
                view.heightAnchor.constraint(equalToConstant: height).isActive = true
            }
        }

        guard let parent else { return }
        guard let constraints = node.constraints else { return }

        if constraints.pinToSuperview == true {
            let top = constraints.top ?? 0
            let left = constraints.left ?? 0
            let right = constraints.right ?? 0
            let bottom = constraints.bottom ?? 0
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: parent.topAnchor, constant: top),
                view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: left),
                view.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -right),
                view.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -bottom)
            ])
        }

        if constraints.centerX == true {
            view.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
        }
        if constraints.centerY == true {
            view.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        }
        if let width = constraints.width {
            view.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = constraints.height {
            view.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
