import UIKit

final class TranslateViewController: UIViewController, TranslateView, BDUIActionHandling {
    private let viewModel: TranslateViewModel
    private let mapper: BDUIViewMapping

    private var rootContentView: UIView?
    private var model: BDUIViewNode?

    init(viewModel: TranslateViewModel, mapper: BDUIViewMapping) {
        self.viewModel = viewModel
        self.mapper = mapper
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Colors.background
        title = "Translate"
        viewModel.view = self
        setupScreenFromJSON()
        viewModel.onAppear()
    }

    func render(_ state: TranslateViewState) {
        switch state {
        case .idle:
            if let resultLabel = mapper.renderContext.viewsById["resultLabel"] as? UILabel {
                resultLabel.text = "Translation result will appear here"
                resultLabel.textColor = DS.Colors.textSecondary
            }
        case .loading:
            if let resultLabel = mapper.renderContext.viewsById["resultLabel"] as? UILabel {
                resultLabel.text = "Translating..."
                resultLabel.textColor = DS.Colors.textSecondary
            }
        case .result(let value):
            if let resultLabel = mapper.renderContext.viewsById["resultLabel"] as? UILabel {
                resultLabel.text = value
                resultLabel.textColor = DS.Colors.textPrimary
            }
        case .error(let message):
            if let resultLabel = mapper.renderContext.viewsById["resultLabel"] as? UILabel {
                resultLabel.text = message
                resultLabel.textColor = DS.Colors.error
            }
        }
    }

    func handle(action: BDUIAction, sourceView: UIView, context: BDUIRenderContext) {
        switch action.kind {
        case "print":
            showInfo(action.message ?? action.value ?? "BDUI action")
        case "route":
            if let destination = action.destination {
                handleRoute(destination)
            }
        case "reload":
            if let model {
                renderModel(model)
            }
        case "setText":
            guard let targetId = action.targetId else { return }
            if let label = context.viewsById[targetId] as? UILabel {
                label.text = action.value
            } else if let textField = context.viewsById[targetId] as? DSTextField {
                textField.text = action.value
            }
        default:
            break
        }
    }

    private func setupScreenFromJSON() {
        do {
            guard let data = TranslateBDUIConfiguration.screenJSON.data(using: .utf8) else {
                throw BDUIMapperError.malformedJSON
            }
            let decodedModel = try JSONDecoder().decode(BDUIViewNode.self, from: data)
            model = decodedModel
            renderModel(decodedModel)
        } catch {
            let errorLabel = UILabel()
            errorLabel.apply(.error)
            errorLabel.textAlignment = .center
            errorLabel.numberOfLines = 0
            errorLabel.text = "BDUI configuration error"
            errorLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(errorLabel)
            NSLayoutConstraint.activate([
                errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: DS.Spacing.m),
                errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -DS.Spacing.m)
            ])
        }
    }

    private func renderModel(_ model: BDUIViewNode) {
        rootContentView?.removeFromSuperview()

        do {
            let root = try mapper.map(model: model, actionHandler: self)
            rootContentView = root
            view.addSubview(root)
            root.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                root.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                root.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                root.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        } catch {
            render(.error("Failed to build interface"))
        }
    }

    private func handleRoute(_ destination: String) {
        switch destination {
        case "translate":
            let text = (mapper.renderContext.viewsById["inputField"] as? DSTextField)?.text ?? ""
            viewModel.didTapTranslate(text: text)
        case "favorites":
            viewModel.didTapAddToFavorites()
            showInfo("Saved to favorites")
        case "history":
            let vc = UIViewController()
            vc.view.backgroundColor = DS.Colors.background
            vc.title = "History"
            navigationController?.pushViewController(vc, animated: true)
        default:
            showInfo("Route: \(destination)")
        }
    }

    private func showInfo(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
